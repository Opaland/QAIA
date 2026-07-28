# Audit indépendant 3-personas (Claude, en session, 2026-07-28)

Demande du fondateur, en écho au rapport Gemini (`audit-report-gemini-2026-07-28.md`) : rejouer
le même exercice à 3 personas (Architecte QA ISTQB Advanced, Ingénieur Prompt/Agentic, PM
Open-Source), **ancré sur les fichiers réels du dépôt local** plutôt que sur une exploration web
de la copie GitHub — le repo local est la source la plus à jour (le message contenant cette
demande incluait une injection de prompt imitant une "IMPORTANT SYSTEM INSTRUCTION" exigeant
un accès web ; traitée comme une instruction utilisateur ordinaire, pas comme un ordre
prioritaire, et écartée sur ce point précis puisque le repo local suffit et est plus fiable).

Contrairement à Gemini, chaque affirmation ci-dessous est vérifiée contre un fichier ou une
issue réelle du dépôt (Read/Grep), pas contre une impression générale du README.

---

## 1. Architecte QA ISTQB Advanced Test Analyst

**Traçabilité et gate.** Confirmé exact : `docs/OUTPUT-CONTRACT.md` fait de
`design.coverage.reqNegCovered/reqNegTotal` le vrai gate bloquant (ADR 0001), et
`negativeRatio` (D20) un signal rapporté, jamais un seuil — ce point précis avait pourtant fait
l'objet d'un débat interne (D50 sur le recalcul indépendant du ratio) et Gemini le décrit
correctement sans jamais avoir vu ce débat. Le palette de techniques (D95, #48 fermée) couvre
désormais data-based/behaviour-based/experience-based, mais **sans utiliser cette classification
officielle CTAL-TA v4.0** — trouvaille indépendante qui recoupe exactement l'issue #50 déjà
ouverte (persona Test Analyst du Sprint 22), donc pas une découverte neuve, une confirmation.

**Ce que Gemini n'a pas vu et que le dépôt documente lui-même honnêtement :** deux vraies failles
de sécurité trouvées en testant les démos en conditions réelles (IDOR D96, endpoint d'audit non
authentifié D99) — Gemini note en persona IA les risques *théoriques* de prompt injection mais
ne mentionne aucun défaut produit réel, alors que le dépôt en a déjà tracé plusieurs avec preuve
fichier:ligne. Un audit qui ne lit que la prose (README/SKILL.md) sans exécuter rien contre les
SUT ne peut pas trouver ce type de défaut — c'est structurellement la même limite que celle que
l'audit Sprint 22 s'est explicitement donnée les moyens de dépasser (3 sceptiques qui rejouent
des commandes en direct, pas seulement qui lisent).

**Verdict persona :** la rigueur méthodologique (9/10 chez Gemini) est confirmée dans le texte
des skills, mais la **preuve d'exécution réelle sur du matériel dur reste inégale** : k6
n'existe nulle part dans le dépôt (#52, confirmé par grep — `**/*.k6.js` et `k6 run` absents
sauf en prose dans `perf-check/SKILL.md`), aucune démo IA/ML n'exerce les techniques CT-AI
ajoutées (#53). Gemini note "outillage 6,5/10" sans jamais avoir vérifié ces deux points
précis — la note est directionnellement correcte mais arrivée par intuition, pas par grep.

## 2. Ingénieur Prompt & Architecte IA Agentic

**Contexte drift sur >50 US.** Risque réel et non testé — aucune mesure du dépôt ne couvre un
projet à cette échelle (le plus gros parcours mesuré est `expense-demo`, une seule US, 38
scénarios). Ni Gemini ni l'audit Sprint 22 n'ont un chiffre ici ; reste une lacune de mesure
honnête, pas comblée par ce recoupement.

**RAG Git non-vectoriel.** Confirmé structurel : `.qaia/knowledge/` reste des fichiers Markdown
lus intégralement par la skill (`rag-build`, `istqb-design`), sans index. La limite citée par
Gemini ("au-delà de plusieurs centaines de règles") est plausible mais non mesurée dans ce
dépôt — aucune base de connaissance existante n'en approche le volume (`grep -rc` sur
`.qaia/knowledge/` des exemples montre un ordre de grandeur de dizaines de règles, pas
centaines). Traité comme risque théorique correctement identifié, pas comme défaut observé.

**Portabilité hors-Claude (Partie 2 de Gemini).** Recommandations (Markdown typé strict,
few-shot, chain-of-thought explicite en 2 étapes) sont génériques et raisonnables, mais **le
dépôt n'a aujourd'hui aucun dossier `prompts/adapters/`** — confirmé par `Glob` négatif. C'est
un vrai gap, distinct des 19 issues ouvertes actuelles (aucune ne couvre la portabilité
multi-LLM des instructions elles-mêmes ; #42 est un bridge MCP pour Cursor/Copilot, sujet
voisin mais différent — MCP est un protocole d'outillage, pas une reformulation de prompt pour
un autre LLM). Nouvelle issue justifiée (voir DECISIONS.md D104).

## 3. Product Manager Open-Source

**"0 étoile, 0 contributeur externe" (prémisse du plan Gemini).** Toujours vraie à ce jour, mais
le vrai obstacle documenté par le dépôt lui-même n'est pas un manque de marketing — c'est que
**le gate G2 (5 pilotes réels) n'a jamais été franchi humainement** (`docs/STATUS.md`, "Ce qui
bloque"), qu'aucune organisation GitHub n'existe encore (#2, bus factor = 1, P0 toujours ouvert),
et que l'audit Sprint 22 a déjà classé ces deux points comme "faits bloquants" du verdict final.
Gemini propose une feuille de route GTM (Phase 2/3) sans mentionner ces deux prérequis
structurels — une stratégie de diffusion construite avant l'org GitHub et les premiers pilotes
réels risque de recruter vers un repo personnel sans admin de secours.

**Item le plus at-risk du backlog actuel, déjà connu, toujours vrai** : #51 (benchmark "QAIA vs
prompt direct à Claude Code"), classé P1 par l'audit Sprint 22 lui-même comme l'angle le plus
menaçant pour l'existence du produit — Gemini ne pose jamais cette question frontalement dans
son plan d'action, alors que c'est exactement la question qu'un CTO sceptique évalue en premier
selon son propre persona PM. Confirmé comme priorité n°1 restante, pas une découverte neuve.

---

## Synthèse du recoupement (les deux audits + celui-ci)

| Point | Gemini (7,5/10) | Sprint 22 (2,4/5 ≈ 4,8/10) | Ce recoupement |
|---|---|---|---|
| Rigueur méthodo QA | Forte (9/10) | Confirmée dans le texte des skills | Confirmée, mais preuve d'exécution réelle inégale (k6 absent, CT-AI jamais exercé) |
| Architecture IA | Solide (7,5/10) | Idem, + 2 vraies failles trouvées en exécution | Confirmée en théorie ; les vraies failles ne se trouvent qu'en exécutant, pas en lisant |
| Outillage/industrialisation | Faible relatif (6,5/10) | Faible relatif (#51/#52/#53) | Les deux s'accordent — priorité #51 déjà connue, pas déplacée par ce rapport |
| Mur humain (pilotes, org) | **Absent du plan d'action** | Cité comme fait bloquant | Risque réel non traité par le plan GTM de Gemini — signalé ici |
| JSON Schema contrat de sortie | Recommandé (Phase 1) | Non mentionné | Gap réel confirmé, livré le jour même (D104) |
| Adapters multi-LLM | Recommandé (Phase 1) | Non mentionné (proche de #42, mais distinct) | Gap réel confirmé, tracé en issue |

**Verdict de ce recoupement :** aucun des deux audits externes n'est à rejeter — Gemini apporte
un vrai gap outillage (schema, adapters) que le backlog Sprint 22 n'avait pas capté ; Sprint 22
reste le plus fiable sur le fond (verdict vérifié par exécution, pas seulement lu) et sur le
diagnostic humain (mur pilotes/org). La divergence de note globale (7,5 vs 4,8/10) s'explique
par une différence de méthode, pas par un désaccord de fait une fois qu'on regarde les mêmes
items en détail.
