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
| A | groq | non | ÉCHEC | — | 37 | 8 |
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

**1. La langue de sortie n'est écrite nulle part.** Groq a produit du Gherkin **en français** —
`Scénario:`, `Etant donné`, `Lorsque`. Il a même tenté un en-tête `# Language: fr`, avec une
majuscule là où la norme veut une minuscule.

C'est **exactement la faute que l'auteur de ce dépôt a commise le matin même** en écrivant le
cahier json-server en français, refusé par la CI. Le modèle et l'humain ont échoué sur le même
silence : `testbook-generate` ne dit pas dans quelle langue émettre.

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
`.gherkin-lintrc`, et les cahiers d'exemple dont les modèles copient la forme.

Ce n'est pas un problème de contenu de skill : c'est un problème de **contrat d'émission implicite**.
La skill décrit *quoi* produire et suppose que l'hôte sait *sous quelle forme*.

Deux modèles sur quatre franchissent quand même la barre en bras A, et le meilleur reproduit la
référence à l'identifiant près. Le contenu est portable ; **c'est sa mise en forme qui ne l'est
pas.**

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
