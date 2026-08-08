# Portabilité : ce qui casse quand la skill quitte Claude Code (2026-08-08)

Première mesure exigée par [ADR 0006](../../docs/adr/0006-multi-agent-portability.md), qui impose
un ordre : **mesurer d'abord, corriger ce qui est mesuré, ne packager qu'ensuite.**

Le dépôt revendique « 100 % Markdown, aucune clé, portable ». Cette promesse n'avait **jamais été
éprouvée**. On avait vérifié que les instructions survivent à un changement de *modèle* ; jamais
qu'elles survivent à un changement d'*hôte*.

## Protocole

Skill mesurée : `testbook-generate`, sur **son entrée réelle** — les points de contrôle
`03-design.md` et `04-priorities.md` archivés de la vraie chaîne US-004, pas une approximation.

Une question s'est posée avant même d'envoyer : la skill renvoie vers `references/`, que Claude
Code charge **à la demande**. Un appel d'API ne reçoit que ce qu'on lui colle. D'où deux bras :

| Bras | Contenu | Ce qu'il représente |
|---|---|---|
| **A** | `SKILL.md` seule — 22 703 caractères | un portage naïf, ou un hôte sans chargement paresseux |
| **B** | + les deux références inlinées — 31 050 caractères | un portage correct |

**L'écart mesure 8 347 caractères** : 27 % de la spécification que Claude Code fournit gratuitement.

Cinq fournisseurs, aucune indulgence : chaque sortie est passée au **même linter Gherkin que la
CI**. Verdict binaire, pas impression.

## Résultats

| Bras | Modèle | Bloc de code à retirer | Lint | Scénarios | `@QAIA-` | `@low-confidence` |
|---|---|---|---|---|---|---|
| A | **gemini** | non | **OK** | **38** | **38** | **11** |
| A | groq | non | ÉCHEC | 37 | 37 | 8 |
| A | huggingface | non | ÉCHEC | 38 | 38 | 13 |
| A | **mistral** | **oui** | **OK** | 37 | 37 | 11 |
| B | **gemini** | non | **OK** | **38** | **38** | **11** |
| B | huggingface | non | ÉCHEC | 37 | 37 | 11 |
| B | mistral | oui | ÉCHEC | 37 | 37 | 23 |

*Groq n'a pas de bras B (quota atteint) et Cerebras a répondu « paiement requis » sur les deux.*

**La référence produite sous Claude Code : 38 scénarios, 38 identifiants uniques, 11
`@low-confidence`.** Gemini la reproduit **à l'identique**, dans les deux bras. C'est le signal de
portabilité le plus fort que ce projet ait jamais mesuré.

## L'hypothèse que la mesure réfute

Avant de lancer, j'avais désigné le coupable : le chargement paresseux des `references/`, une
affordance de Claude Code qu'un autre hôte n'a pas. Le bras B existait pour le prouver.

**Il le réfute.** Inliner les références n'améliore rien — et **dégrade Mistral**, qui passe de
`OK` à `ÉCHEC` et dont les scénarios marqués `@low-confidence` doublent, de 11 à 23. Plus de
contexte a produit plus de bruit, pas plus de conformité.

Le vrai blocage est ailleurs, et les échecs le nomment.

## Trois classes d'échec, toutes diagnostiquées

**1. La langue de sortie est écrite — et notre propre phrase suivante la contredit.** Groq a
produit du Gherkin **en français** — `Scénario:`, `Etant donné`, `Lorsque` — avec une tentative
d'en-tête `# Language: fr`, majuscule là où la norme veut une minuscule.

**Correction d'une affirmation publiée trop vite** : la première version de ce rapport disait que la
langue « n'est écrite nulle part ». **C'est faux.** La skill dit explicitement *« Gherkin, English
keywords »*. Vérifié en ouvrant le fichier, après l'avoir écrit.

La vraie cause est plus intéressante que l'omission que j'avais annoncée : la phrase **juste après**
dit *« Scenario content in the project language »*. Un modèle qui lit les deux d'affilée, sur un
projet francophone, bascule raisonnablement **tout** en français — mots-clés compris.

Ce n'est donc pas un silence, c'est une **ambiguïté dans notre propre spécification** : deux clauses
consécutives dont la seconde peut se lire comme annulant la première. C'est exactement la classe de
défaut que QAIA existe pour trouver chez les autres — et l'auteur du dépôt était tombé dans la même
le matin même, en écrivant le cahier json-server en français.

**2. La ligne `Feature:` a été perdue au profit d'un commentaire.** Groq a écrit
`# Feature: US-004` — un commentaire — et **aucune ligne `Feature:` réelle**. Le fichier n'a donc
jamais commencé.

La cause est notre propre convention : nos cahiers commencent par un commentaire `# Feature: …`
*au-dessus* de la vraie déclaration. Vérifié en réinjectant la ligne manquante — le fichier parse
alors, et il ne reste que des erreurs d'indentation.

**3. L'indentation attendue vit dans un fichier que le modèle ne reçoit jamais.** Hugging Face
produit du Gherkin structurellement valide et échoue **uniquement** sur l'indentation. La règle
est dans `.gherkin-lintrc`, à la racine du dépôt. Sous Claude Code, l'agent peut le lire. Ailleurs,
personne ne le lui donne.

## Le vrai blocage, nommé

**Les conventions d'émission de QAIA vivent dans des fichiers que seul Claude Code peut lire** — le
`.gherkin-lintrc`, et les cahiers d'exemple dont les modèles copient la forme. Là où une règle
existe bel et bien dans la skill, c'est notre propre rédaction qui la rend annulable.

Ce n'est pas un problème de contenu de skill : c'est un problème de **contrat d'émission implicite**.
La skill décrit *quoi* produire et suppose que l'hôte sait *sous quelle forme*.

Deux modèles sur quatre franchissent quand même la barre en bras A, et le meilleur reproduit la
référence à l'identifiant près. Le contenu est portable ; **c'est sa mise en forme qui ne l'est
pas.**



> **Correction de ce tableau.** La première version portait « — » pour les scénarios de Groq, en
> affirmant qu'aucun n'avait été produit. **Faux** : il en avait 37, mais mon script de notation ne
> comptait que les mots-clés anglais et ne voyait pas `Scénario:`. L'instrument était en cause, pas
> la sortie. Corrigé, et la suite de cette page raconte deux autres resserrages du même instrument.

## Ce que le correctif a donné : rien, en net

Le contrat d'émission a été écrit dans la skill — langue non annulable, ligne `Feature:`
obligatoire, indentation, interdiction du bloc de code — puis le bras A rejoué deux fois.

| Modèle | Avant | Après | |
|---|---|---|---|
| **gemini** | ✅ 38/38/11 | ✅ 38/38/11 | inchangé |
| **huggingface** | ❌ indentation | ✅ 37/37/11 | **corrigé** |
| **groq** | ❌ français | ❌ français **et 0 identifiant** | **aggravé** |
| **mistral** | ✅ | ❌ ligne `Feature:` perdue | **régressé** |

**Deux conformes avant, deux conformes après.** Le correctif a déplacé les échecs sans les réduire.

## Trois choses apprises, dont aucune n'était prévue

**1. Décrire une convention maison la propage.** Mistral émettait une vraie ligne `Feature:`. En lui
expliquant que notre commentaire `# Feature: …` n'est *pas* la déclaration, on lui a appris à écrire
le commentaire et à **jeter la déclaration**. Vérifié par comparaison avant/après, pas supposé : 1
ligne `Feature:` et 0 commentaire avant ; l'inverse après.

La règle ne mentionne plus l'habitude du projet, et le motif est écrit dans la skill pour que
personne ne la réintroduise.

**2. Une règle explicite ne suffit pas.** La skill disait déjà « English keywords » ; on l'a rendue
non annulable. Groq est revenu au français — cette fois avec un en-tête `# language: fr` correct,
donc **accepté par le linter**. Ce n'est plus un défaut de spécification, c'est une limite du
modèle. Aucune réécriture ne la corrigera.

**3. L'instrument de mesure a dû être resserré trois fois.** Il ne comptait que les mots-clés
anglais — d'où un absurde « OK, 0 scénario ». Puis il acceptait un fichier sans aucun identifiant
`@QAIA-`. **Un fichier qui *lint* n'est pas un fichier *conforme*** : la barre exige le parseur,
**plus** au moins un scénario, **plus** des identifiants stables, **plus** les mots-clés anglais.

Troisième fois dans la même journée que **mesurer coûte plus cher que corriger**, et troisième fois
que l'instrument était le vrai coupable.

## Ce qu'il faut en conclure, sans arrondir

**La portabilité ne se gagnera pas en réécrivant des règles.** Deux modèles sur quatre franchissent
la barre, avant comme après. Le meilleur reproduit la référence à l'identifiant près ; les deux
autres échouent pour des raisons qui leur appartiennent — l'un ignore une consigne explicite, l'autre
perd une ligne structurelle.

Ce qui reste à essayer relève d'un autre levier : **contraindre la sortie plutôt que la décrire**
(un gabarit à remplir), ou **valider et redemander** (émettre, linter, renvoyer l'erreur). Les deux
sortent du périmètre d'une skill Markdown, et c'est un résultat en soi.

## Ce que cette mesure ne couvre pas

- **Une seule skill.** `testbook-generate` produit un artefact vérifiable par machine, ce qui la
  rend mesurable ; les skills conversationnelles ne le sont pas de cette façon.
- **Aucun hôte réel.** C'est un appel d'API, pas Cursor ni Copilot. Le mécanisme d'installation,
  l'accès aux fichiers et l'enchaînement entre skills ne sont **pas** testés.
- **Une exécution par modèle.** Aucune mesure de variance.
- **Un seul jeu d'entrée**, sur un domaine que le projet connaît bien.

## Sorties brutes

`A/` et `B/` contiennent chaque `.feature` tel qu'il a été rendu, avant toute correction.
`arm-A-skill-only.txt` et `arm-B-with-references.txt` sont les prompts exacts envoyés.
