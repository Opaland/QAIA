# QAIA — état du projet & prompt de reprise

Dernière session : 2026-07-25 (merge vers `main` fait, backlog GitHub resynchronisé, **mandat élargi post-M0** : gate G2 levée par le fondateur — D67 —, veille concurrentielle faite, backlog remodelé, démonstration hors médical en cours). Ce document donne l'état honnête du projet et un **prompt prêt à coller** pour reprendre le travail plus tard (y compris en Claude Code **local** : tout est poussé sur `main`, le pickup est immédiat).

## Mandat en cours (D67, 2026-07-25)

Le fondateur a levé le gate G2 (5 pilotes réels) et donné un mandat élargi : veille
concurrentielle (faite, `docs/COMPETITIVE-ANALYSIS.md`), remodelage du backlog (fait — #1/#5/#23
fermées ou reformulées, #29/#30 débloquées, 10 nouvelles issues #33-#42), extension du produit
à un domaine non-médical (en cours, `examples/expense-demo/` sur US-004), puis relance du
développement en autonomie sur le backlog remodelé. Objectif final : un projet montrable,
docs à jour, diffusable, sans bug évident — pas seulement sur le médical.

## Où on en est

**Le produit existe et est éprouvé (en automatique, et maintenant aussi sur du matériel dur réel). Trois plugins.**
- **`qaia-core` 0.2.9** — 15 skills : parcours complet US → cahier Gherkin (`us-ingest` [+ connecteur Jira #9], `us-review`, `need-understanding` [numérotation corrigée, audit prompt management], `rag-build`, `istqb-design` [RAG-in-use + 2 amendements #24], `oracle-generate` [+ oracle projet OpenAPI #16, durci #25], `prioritize` [audité, A/B testé — D52], `testbook-generate`, `report` [manifeste standardisé], `testbook-export`, `feedback`) + `qaia` (méta-agent ReAct), `qaia-help`, `testbook-validate` [+ pass structurel déterministe, D45], `hello`.
- **`qaia-playwright` 0.1.2** — 6 skills : `automate` (Gherkin → Playwright POM **+ pipeline CI**), `a11y-audit`, `visual-check` (régression visuelle), `perf-check`, `security-surface`, `run-report`.
- **`qaia-score` 0.1.1** — score uniquement, lecture seule : `testbook-score` (rubrique ISTQB /20 + top-3, **+ pass structurel DÉTERMINISTE step 0** : score reproductible séparé du juge LLM, sniffer anti-fabrication #27, détecteurs C1/C2 #28), `aptitude-gate` (PASS/CONCERNS/FAIL/WAIVED). N'écrit que le bloc `gate` ; aucun producteur ne se score lui-même.

**Session 2026-07-25 — corpus élargi 24 cas TERMINÉ (lots 2-6, 20 cas clean-room via agents
parallèles) :** Reprise après un plantage de session (rien perdu, tout committé). Les 5 lots
restants (C1-C20) ont été exécutés via des agents indépendants en parallèle (4 par lot),
chacun rédigeant son propre ticket clean-room, sa propre génération Claude fidèle aux 3
skills, et ses propres appels aux fournisseurs externes. **Bilan global (D58-D64,
`eval/baselines/corpus-24-depth.md`)** : **Claude 24/24 cas sans défaut de détection** ;
**Gemini le fournisseur externe le plus fiable** (0 échec de détection sur 21 cas
disponibles, ratio négatif D20 auto-rapporté systématiquement exact, mais 4 défauts annexes
de fabrication non flaguée cumulés) ; **Groq et Mistral échouent chacun ~25-33 % des cas** à
raisonnement multi-règles ou `Then` vérifiable (sans-faute sur CRUD-inverse/traçabilité) ;
**Hugging Face couverture partielle (13/24 cas)**, le profil de défauts le plus dense (6
distincts) puis indisponibilité opérationnelle (crédit gratuit épuisé, `402`) sur les 11
derniers cas. **2 défauts transversaux confirmés à l'échelle du corpus entier** : le ratio
négatif D20 auto-rapporté est peu fiable chez tous sauf Gemini (valide fortement D50) ; le
détecteur `structural_score.py` (`VAGUE_RE`/`HOLLOW_RE`) a un angle mort sur les formulations
paraphrasées, confirmé 3 fois (C5, C10, C18) — **non corrigé cette session, backlog explicite**.
CRUD-inverse et traçabilité des IDs généralisent fortement (quasi aucun échec sur 24 cas).
Le produit QAIA lui-même (3 skills testés) n'a montré aucune régression — la variance mesurée
est modèle-dépendante, pas skill-dépendante.

**Session 2026-07-24 (ter, suite 13) — corpus élargi 24 cas, lot 1/6 (profondeur statistique) :**
Suite à D55-D57 (balayage en largeur, N=1/skill) : demande fondateur de creuser en profondeur
sur du matériel neuf pour voir si les patterns tiennent à plus grande échelle. Plan à 24 cas
(4 réels GitLab CE + 20 clean-room répartis par format/domaine, `eval/goldset-hardened/corpus-24-plan.md`).
**Lot 1/6 exécuté** (4 cas réels GitLab CE v8.16.9, jamais utilisés cette session) sur Claude +
Groq + Hugging Face + Mistral (Gemini rate-limité après le 1er cas, décision fondateur de
continuer sans lui). **2 nouveaux défauts** : Hugging Face invente des codes HTTP précis
(201/404/409) sur un ticket sans API REST mentionnée (4e défaut distinct trouvé chez HF cette
session) ; Mistral invente une exception "propriétaire" non fondée sur une page de visibilité
publique. Signal plus léger confirmé (dédup tautologique Groq/Mistral). Sans-faute total sur le
piège précondition SSH (5/5 modèles). Décision D58. Preuve : `eval/baselines/corpus-24-depth.md`.
**Reste** : lots 2-6 (20 cas clean-room), même protocole, par lots de 4-6 pour respecter les
paliers gratuits.

**Session 2026-07-24 (ter, suite 12) — balayage multi-modèles COMPLET, 23/23 skills :**
Demande fondateur : étendre le harnais de gap à tous les skills, vérifier systématiquement
sur 4+ modèles gratuits (Gemini, Groq, Hugging Face, Mistral ; Cerebras ajouté mais bloqué
côté compte). **Bilan** : 3 défauts réels trouvés, tous sur les 9 skills à jugement ouvert du
cœur du pipeline (Groq/raisonnement multi-règles profond, Mistral/traçabilité de provenance,
Hugging Face/3 défauts distincts dont une fuite de PII présentée comme "sanitized") ; **0
défaut** sur les 14 skills à règles mécaniques/ordonnées explicitement (tout
`qaia-playwright`, `qaia-score`, `hello`, `qaia-help`) — y compris un test de sécurité
(injection via nom de fichier) où aucun des 5 modèles n'a cédé. Décisions D55-D57. Preuve
complète : `eval/baselines/multimodel-skill-sweep.md`.

**Session 2026-07-24 (ter, suite 6) — prompt management sur les 23 skills + second juge :**
Demande fondateur : auditer précision/format/exemples des 23 skills, et outiller un second
juge LLM indépendant (multi-fournisseur gratuit, en repli : Gemini → Groq → Hugging Face).
**Trouvé et corrigé** : un doublon de numérotation dans `need-understanding` (deux étapes
"4."). **Second juge livré et vérifié en live sur les 3 fournisseurs** (2 défauts trouvés en
l'exécutant réellement : 403 urllib/User-Agent sur HF, format de réponse Gemini mal
documenté par une source web résumée) — converge avec le juge Claude et le scoreur
déterministe sur le même défaut C1 (accord tri-source). `eval/tools/second_judge.py`,
`.env`/`.gitignore` ajoutés (secrets jamais commis, jamais dans le produit livré — D29
intact). **Premier test A/B contrôlé sur un skill** (`prioritize`, avec/sans exemple
chiffré) : résultat négatif honnête — l'exemple testé aurait dégradé la calibration (sur-
généralisation "chemin négatif → probabilité plus haute" jusqu'à un contrôle d'auth
générique), **pas appliqué**. Décisions D51-D52. Preuves : `eval/baselines/second-judge.md`,
`eval/baselines/prioritize-ab-test.md`. Reste : auditer `qaia` (méta-agent, identifié comme
le skill le plus vague du corpus) si on continue le prompt management.

**Session 2026-07-24 (ter, suite 2) — non-régression des amendements #24 échantillonnée :**
2 cas réels neufs (GitLab CE `dashboard.feature`, Diaspora `two_factor_authentication.feature`),
jamais vus par les runs d'origine, soumis en tickets durs. **Les 2 amendements généralisent** :
le gap des entités-sœurs est explicitement flagué (pas silencieux) sur le Dashboard ; le tag
`@low-confidence` est correctement posé sur la désactivation 2FA et la régénération des codes
de récupération. Limite assumée : pas un re-run complet des 50 US (pas de mesure de
rappel/précision agrégée) — signal de généralisation, pas clôture définitive. Preuve :
`eval/baselines/istqb-amendments-regression-24.md`, décision D48.

**Session 2026-07-24 (ter, suite) — #25 durci en enchaînement autonome :** `oracle-generate`
(`oracles/openapi.md`) reçoit un **step 0** obligatoire : résolution `$ref` interne avant toute
lecture de contrainte (un noeud non résolu perdait les négatifs de champ requis en silence), et
avertissement explicite **« spec sous-documentée »** (0 erreur 4xx/5xx documentée sur tout le
spec, ou mutations sans auth déclarée) au lieu de dégénérer silencieusement vers `[open]`
partout. Règle **re-vérifiée en re-fetchant les 3 vraies specs** du constat initial
(Petstore/apis.guru/Notion) — la première mouture aurait manqué apis.guru (méta-API en lecture
seule), corrigée avant livraison. `qaia-core` 0.2.7→0.2.8. Preuve :
`eval/baselines/connectors-real-data.md`, décision D47.

**Session 2026-07-24 (ter) — harnais de gap #24 exécuté sur du matériel réel (accès web) :**
2 cas durs sourcés sur le web (GitLab CE `groups.feature` sans narratif US, Sharetribe champs
custom pilotés par config admin), 4 runs isolés (3× sur le cas Groups pour la variance).
**Résultats honnêtes** : mode 2 (config-driven) confirmé tenu sur cas neuf, zéro régression ;
mode 4 (variance) confirmé significatif (29→42 scénarios, +45 %, sur ticket identique) ; mode 1
(extraction) → **2 défauts trouvés et corrigés** dans `istqb-design` (silence sur les
entités-sœurs non nommées, fabrication convergente non flaggée d'une sémantique de
suppression) ; mode 3 (redondance) → détecteur déterministe ajouté à `structural_score.py`,
qui a lui-même révélé et corrigé un faux positif sur du contenu réel (C1 se déclenchait sur le
mot "image" seul). `testbook-validate` reçoit désormais le même pass structurel déterministe
que `testbook-score` (D45). Preuves : `eval/baselines/gap-harness-24.md`,
`eval/goldset-hardened/real-cases-24.md`, `eval/baselines/structural-score.md` (mis à jour).
Décisions D44-D46. **Non fait** : re-mesure des 50 US de `groundtruth-corpus.md` avec les 2
amendements — honnêtement marqué comme suivi, pas encore validé à grande échelle.

**Session 2026-07-24 — le meilleur d'IATS, en autonomie :** lecture des **vrais docs IATS** (Google Drive, dossier *Softway Medical*) → rétrospective honnête `docs/IATS-RETROSPECTIVE.md` (cas réel US 676266 : 100/100 machine vs 58/100 humain ; FinOps confirmé comme régression). **Score structurel déterministe** (`eval/tools/structural_score.py` + `eval/baselines/structural-score.md`, gold set durci `eval/goldset-hardened/`) — discrimine 100/PASS vs C1/C2/fabrication FAIL. **Connecteurs testés sur données réelles** (`eval/baselines/connectors-real-data.md` : oracle OpenAPI dégénère en silence sur specs sous-documentées #25 ; Jira sur réponse réelle). **Gouvernance ADR 0002 / D42-D43** (révise D14) : Python en session autorisé ; hooks/MCP/agents = tier opt-in post-pilote (#29 hook budget, #30 agent ReAct). Nouvelles issues : #18-#30.
- **Contrat de sortie standardisé (D39)** : un unique manifeste JSON par US (`docs/OUTPUT-CONTRACT.md`, contrat 1.0) que tous les plugins écrivent au même format — socle du scoring et de tout export/CI.
- Les trois valident `claude plugin validate --strict`. CI durcie (supply-chain, DCO, gherkin-lint). Marketplace prêt (3 plugins).

**Session 2026-07-23 (bis) — 6 chantiers livrés en autonomie :** contrat de sortie standardisé (D39), plugin de score `qaia-score` (D40), RAG en usage réel (protocole récupération/citation + conditions tirées des règles, `examples/rag-demo/`), oracle projet OpenAPI (D36b, `#16`), connecteur Jira (D9, `#9`, `examples/jira-demo/`), durcissement M3 `automate` (D41, `#10` : scaffold + templates CI + gate T17 honnête). Démos : `examples/scoring-demo/`, `rag-demo/`, `jira-demo/`, `oracle-demo/` (+OpenAPI).

**Ce qui a été mesuré (pas affirmé) :**
- Rubrique gold-set : **médiane 17→19/20** sur 5 US, défauts critiques fermés (C1).
- Exemple exécutable réel `examples/medibook/` : **31 tests Playwright verts, 7 types** (E2E desktop+mobile, API, a11y, visuel, sécu, perf).
- **Campagne robustesse** (50 vrais specs + 18 monkey) : **2 blocages sécurité trouvés et corrigés** (PII, abus), 6 gates ajoutés, saturation. `eval/baselines/robustness-campaign.md`.
- **Éval vérité-terrain** (50 paires US+tests humains validés, gitlab/diaspora/sharetribe) : **généralisation prouvée sans overfitting** (held-out ≥ train), **précision ~93 %**, **+200 scénarios valides** au-delà des humains. Plafond honnête (config-driven → RAG). ⚠️ mesure de rappel bruitée. `eval/baselines/groundtruth-training.md`.

**Décisions** : 38 décisions + 17 défauts tracés dans `docs/DECISIONS.md`. Étude BMAD intégrée (`docs/BMAD-ANALYSIS.md`).

## Ce qui bloque (et qui n'est pas à la main d'un agent)

Le seul vrai mur est **humain** — issues [#1](https://github.com/Opaland/QAIA/issues/1) (5 pilotes, gate G2) et [#3](https://github.com/Opaland/QAIA/issues/3) (relire le contrat). Tout est validé en mode *non-interactif* : seuls de vrais testeurs valideront le parcours conversationnel. Kit prêt : `docs/PILOT-KIT.md` (15 min) ; message de recrutement dans `docs/OWNER-GUIDE.md`.

## Prochains leviers (par ordre de valeur)

Les 4 leviers skill-level de la session précédente sont **construits** (RAG-in-use, M3 automate, oracle OpenAPI, Jira) ; le harnais de gap #24, le durcissement #25, et leur contrôle de non-régression sont désormais **exécutés**. Le backlog agent-faisable identifié pour ce cycle est **épuisé** — ce qui reste est le mur humain.

**Fait cette session (2026-07-24 ter), agent-faisable sans pilote :**
1. **#24** — 4 modes mesurés sur 2 cas durs réels sourcés sur le web, 2 défauts trouvés et corrigés dans `istqb-design`, déterminisme branché sur `testbook-validate`.
2. **#25** — avertissement spec sous-documentée + résolution `$ref` obligatoire, re-vérifié sur 3 vraies specs.
3. **Contrôle de non-régression échantillonné** des 2 amendements `istqb-design` sur 2 cas neufs (signal de généralisation, pas un re-run complet des 50 US — limite assumée, `eval/baselines/istqb-amendments-regression-24.md`).
4. **Grooming backlog** : le gate D20 (ratio négatifs) était déjà résolu par ADR 0001 mais pas re-groomé — fait.

**Restant, sans nouveau levier agent-faisable identifié :**
- ~~Généraliser le sniffer/déterminisme au vrai corpus IATS~~ — **abandonné** (décision D49,
  fondateur) : le coût de récupération (Tuleap/ZIP Notion, confidentiel) dépasse la valeur
  puisque #24 fonctionne déjà sur du matériel réel public. Ne pas rouvrir sans raison nouvelle.
- Re-mesurer les 50 US de `groundtruth-corpus.md` en entier (au-delà du contrôle échantillonné) — possible mais coûteux ; à faire si un futur amendement touche encore `istqb-design`, ou avant une release publique/pilote.

**Mur humain (non agent) :**
5. **Recruter les 5 pilotes** (#1, gate G2) — le seul vrai mur. Kit `docs/PILOT-KIT.md`.
6. **M3/T17 sur app pilote**, **RAG chiffré au harnais** (#19), **calibration qaia-score vs humain** (#21) — gate pilote/humain.

**Tier opt-in (post-pilote, ADR 0002) :** #29 hook budget/observabilité (comble #7 FinOps), #30 agent ReAct. Ne pas construire avant G2 (#23, leçon #2).
7. Org GitHub dédiée (optionnel, #2).

> **Note accès web (2026-07-24 ter)** : cette session a confirmé l'accès à `WebSearch`/`WebFetch` (GitHub + web général), utilisé pour sourcer les 2 cas durs réels du #24 — à **reconfirmer en reprise** (l'environnement d'exécution peut varier d'une session à l'autre, ne pas supposer l'accès acquis par défaut).
>
> **Gold set IATS (~88 US) : piste abandonnée (D49, fondateur, 2026-07-24 ter).** Sur
> **Google Drive** (dossier *Softway Medical*, confidentiel), seul le pitch IATS (cas réel
> US 676266) est présent — le gold set des ~88 US N'EST PAS sur Drive, probablement dans
> **Tuleap** ou des exports Notion ZIP non inspectés. Le fondateur a tranché : ne pas
> poursuivre cette piste, le coût (accès Tuleap, dézippage/inspection Notion, tout
> confidentiel/jamais commité) dépasse la valeur puisque le harnais #24 fonctionne déjà sur
> du matériel réel public, réutilisable indéfiniment. **Ne pas rouvrir sans raison nouvelle
> et concrète.**

## Actions propriétaire restantes
Voir `docs/M0-CHECKLIST.md` (détail à jour) et `docs/OWNER-GUIDE.md`. Fait : repo public,
Discussions, branch protection, 2FA. Reste : **merger cette branche dans `main` (squash) puis
la supprimer** — nécessite des droits admin que l'agent n'a pas (pas de `gh` CLI en session,
branch protection active) ; pilotes (#1) ; contrat (#3) ; org (optionnel #2) ; Sponsors/
Security Advisories ; GitHub Projects.

---

## 🔁 Prompt de reprise (à coller dans une nouvelle session Claude Code sur ce repo)

```
Reprends le projet QAIA (plateforme QA agentic open source, plugins Claude Code).
Lis d'abord docs/STATUS.md, docs/DECISIONS.md et docs/KANBAN.md pour le contexte complet.

État : TROIS plugins validés --strict — qaia-core 0.2.9, qaia-playwright 0.1.2, qaia-score
0.1.1. Éprouvé en automatique (gold set 19/20, robustesse 2 failles sécu corrigées, éval
vérité-terrain généralisation prouvée sans overfitting, précision ~93 %) ET sur du matériel
dur réel (harnais de gap #24, 2 cas web, 4 modes d'échec IATS mesurés, 2 défauts corrigés
dans istqb-design — eval/baselines/gap-harness-24.md), et ces 2 amendements ont été
re-vérifiés sans régression sur 2 cas neufs (eval/baselines/istqb-amendments-regression-24.md,
D48 — signal de généralisation, pas un re-run complet des 50 US). Oracle OpenAPI durci
(#25, clos) : avertissement spec sous-documentée + résolution $ref obligatoire, re-vérifié
sur 3 vraies specs (eval/baselines/connectors-real-data.md). qaia-score ET testbook-validate
portent un pass structurel DÉTERMINISTE (séparé du juge LLM) : sniffer anti-fabrication +
détecteurs C1 (AC couvert par image) / C2 (Then non-vérifiable) / redondance (pesticide),
ancrés sur le cas réel IATS US 676266 (preuve eval/tools/structural_score.py +
eval/baselines/structural-score.md). Audit IATS honnête dans docs/IATS-RETROSPECTIVE.md.
Le mur reste humain : 5 pilotes (issue #1, gate G2).

Principes non négociables : distribution 100 % skill (Markdown, sans clé API) ; Python EN
SESSION généré par un skill autorisé (déterminisme sans shipper de code, ADR 0002/D42) ;
hooks/MCP/agents = tier opt-in séparé, jamais dans le cœur, post-pilote (leçon #2) ; sortie
au contrat standard (D39) ; aucun producteur ne s'auto-valide/score (rule 3) ; Gherkin
atomique + IDs stables ; Playwright natif (D5) ; POM-as-fixtures (D34) ; PII masquée + gates
abus/not-a-spec (D37) ; rappel honnête > fabriqué (D38) ; connecteurs portable-first (D29) ;
outils d'abord, pipelines ensuite ; toute modif de skill se mesure au harnais eval/ (ni
régression ni overfit) ; le board GitHub est la source de vérité — toute trouvaille = une issue.

Travaille en autonomie par sprints : une modif → validation --strict → mesure au harnais
→ commit signé (git commit -s) → push sur la branche de travail. Pas de PR sans demande
explicite. Ne relance un run d'agents que s'il peut trouver une classe de défaut nouvelle.

Vérifie d'abord si WebSearch/WebFetch sont disponibles dans cette session (ça a varié d'une
session à l'autre) — si oui, ça permet de sourcer du matériel dur réel comme pour #24.

#24, #25 et leur contrôle de non-régression sont clos ; le backlog agent-faisable identifié
sans pilote est **épuisé** pour ce cycle (le gate D20 a aussi été groomé — déjà résolu par
ADR 0001, juste pas re-documenté). Vérifie d'abord s'il reste un levier agent-faisable non
identifié dans le board GitHub (issues ouvertes non listées dans STATUS.md) avant de conclure
au mur humain. Sinon, le seul vrai prochain pas est le mur humain (#1, 5 pilotes) — pas à la
main d'un agent : dis-le clairement plutôt que d'inventer du travail marginal.

Le gold set IATS confidentiel (~88 US) est **abandonné pour de bon** (D49, décision fondateur) :
ne pas proposer de le récupérer via Tuleap/ZIP Notion sauf si le fondateur relance
explicitement le sujet.

Prompt management engagé sur les 23 skills (précision/format/exemples) : 1 bug de
numérotation corrigé (need-understanding), 1 test A/B fait (prioritize, résultat négatif
honnête, rien appliqué — D52). `eval/tools/second_judge.py` ajouté : second juge LLM
indépendant en repli gratuit (Gemini/Groq/HF), outillage mainteneur uniquement (jamais dans
le produit, D29 intact), vérifié en live sur les 3 fournisseurs (D51). Secrets dans `.env`
(gitignored) — si absent/vide en reprise, les credentials ne sont plus valides (déjà exposés
en chat, jamais réutiliser une clé qui a transité en clair) ; redemander au fondateur si le
second juge doit être réactivé. Candidat suivant si le prompt management continue : `qaia`
(méta-agent ReAct), identifié comme le skill le plus vague du corpus (pas d'exemple concret
de ce qu'un bon raisonnement ReAct produit).

**Corpus élargi 24 cas : TERMINÉ (D58-D64)**, plan `eval/goldset-hardened/corpus-24-plan.md`,
preuve complète et bilan global `eval/baselines/corpus-24-depth.md`. Ne pas relancer de
nouveaux lots sans une demande explicite du fondateur — le plan à 24 cas est épuisé.
**Correctif `VAGUE_RE`/`HOLLOW_RE` fait (D65)** : les 2 vrais gaps (C5, C18) sont corrigés et
vérifiés sans régression (7 fixtures + 15 fichiers réels du corpus) ; le 3e cas (C10) s'est
avéré ne pas être un vrai bug à l'examen. Nouvelle fixture `eval/goldset-hardened/paraphrased-vague.feature`.
Limite résiduelle assumée et non corrigée : `ASSERT_RE` trop permissif sur les guillemets
autour d'un identifiant d'entité (masque un `Then` par ailleurs vague) — à reprendre si un
futur cas la reproduit.

**Merge vers `main` : FAIT (2026-07-25, D66).** Le fondateur a explicitement demandé de le
faire malgré la réserve propriétaire (M0-CHECKLIST #3) ; push d'abord bloqué par le
classificateur du mode auto, refait après autorisation explicite, réussi (`main` = `ec0529e`,
squash, historique complet conservé sur la branche source). Reste M0-CHECKLIST #3 côté
suppression de la branche source — pas fait, à décider séparément.

**Backlog GitHub resynchronisé (D66).** Le connecteur MCP GitHub a été connecté (PAT
personnel — un premier token collé en clair dans le chat a été traité comme compromis et
jamais utilisé, conformément à D51). 6 issues fermées (#6, #24, #25, #26, #27, #28), 2
nouvelles ouvertes reprenant le backlog technique de cette session : **#31** (limite
résiduelle `ASSERT_RE` trop permissif sur les guillemets) et **#32** (Hugging Face jamais
mesuré sur C10-C20, crédit épuisé). Le board GitHub est de nouveau la source de vérité pour
ce backlog — ne pas le dupliquer ici.

Autre piste ouverte, pas encore en issue : le prompt management (`qaia` méta-agent, candidat
identifié en D51-D52) reste disponible si le fondateur veut continuer sur ce terrain plutôt
que le corpus.

Vérifie d'abord si `.env` contient toujours des credentials valides pour Gemini/Groq/HF/
Mistral (secrets jamais réutilisés une fois exposés en clair — redemander au fondateur si
absents/expirés) avant de relancer quoi que ce soit qui appelle `multi_model_generate.py`.
Vérifie aussi si `GITHUB_PERSONAL_ACCESS_TOKEN` est toujours valide dans `~/.claude/settings.json`
avant de compter sur le connecteur GitHub.
```
