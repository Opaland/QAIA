# Rapport d'audit externe — Gemini (2026-07-28)

**Source :** rapport collé par le fondateur en session (auteur déclaré : "comité d'experts"
simulé par Gemini, PARTIE 1/2/3). Reproduit ici tel que reçu, pour trace et comparaison avec
`audit-report.html` (Sprint 22, revue multi-persona Claude/Workflow, 2026-07-26).

**Statut de vérification :** non re-vérifié claim par claim comme l'a été l'audit Sprint 22
(pas de revue adversariale à 3 sceptiques ici). Traité comme une **seconde opinion externe**,
comparée point par point à l'état réel du dépôt (docs/DECISIONS.md, docs/STATUS.md,
docs/KANBAN.md) — voir `docs/DECISIONS.md` D104 pour le verdict de recoupement.

---

## PARTIE 1 : AUDIT DE MATURITÉ TECHNIQUE

### 1. Architecture IA & Prompt

**Pari "Zero-Key / Skill-based" vs Agent MCP Runtime.** Forces citées : sécurité/zero-trust
(pas de fuite de clé API, pas de coût SaaS récurrent, pas d'exécuteur distant vulnérable aux
prompt injections indirectes), adoption zero-friction (clonage Git ou import de skill).
Faiblesses citées : dépendance contextuelle extrême (risque de *context drift* sur les projets
>50 US), non-autonomie relative (pas d'inspection DOM interactive pour les sélecteurs Playwright
sans MCP).

**Contrat de sortie (`OUTPUT-CONTRACT.md`) & RAG local versionné.** Jugé "d'une grande rigueur
formelle" — transforme l'IA générative en compilateur de spécifications. RAG Git jugé
performant pour 1-20 microservices/modules, mais sans indexation vectorielle au-delà de
plusieurs centaines de règles métier.

**Isolation `qaia-score` en Read-Only.** Jugée efficace pour résoudre le biais d'auto-évaluation
classique des LLM.

### 2. Méthodologie QA (angle ISTQB)

Workflow shift-left jugé viable pour environnements réglementés (traçabilité ISO 13485/FDA 21
CFR Part 11 via IDs stables `TC-XXX` conservés US → Gherkin → Playwright), règle des 40% de
cas négatifs jugée force les techniques ISTQB (analyse valeurs limites, partitionnement).
Régénération par diff au niveau du scénario jugée "clé de voûte de l'utilisabilité dans le
temps".

### 3. Grille de notation

| Critère | Note /10 |
|---|---|
| Rigueur méthodologique QA | 9 |
| Architecture IA & robustesse | 7,5 |
| Outillage & industrialisation | 6,5 |
| **Maturité globale** | **7,5** — "prêt pour le pilote en équipe de production" |

---

## PARTIE 2 : PORTABILITÉ HORS-CLAUDE

Décrit comment extraire le "prompt système" (`SKILL.md` + `OUTPUT-CONTRACT.md`) vers un chat
web (ChatGPT/Gemini Advanced, custom instructions + knowledge base manuelle) ou un pipeline
CI/CD (script d'orchestration appelant une API structured-outputs, parsant la réponse,
committant). Recommande : remplacer les balises pseudo-XML par du Markdown typé strict
(`CRITICAL_RULE_1`), ajouter du few-shot obligatoire pour les contraintes négatives (≥40%),
exiger un chain-of-thought explicite en 2 étapes (analyse puis génération).

## PARTIE 3 : PLAN D'ACTION

- **Phase 1 (T1 2026, technique)** : compression/minification des skills (token budget),
  formalisation JSON Schema du contrat de sortie, dossier `prompts/adapters/` multi-LLM
  (OpenAI/Gemini/Ollama).
- **Phase 2 (T2-T3 2026, GTM)** : activer `PILOT-KIT.md`, positionnement "Privacy-First /
  Zero Lock-in" face aux SaaS (Testim, Mabl, Octane AI), cibler Lead QA en secteurs réglementés,
  publier des benchmarks publics.
- **Phase 3 (T4 2026+, industrialisation)** : CLI autonome (`qaia-cli`, npm/pip), GitHub Action
  officielle, gouvernance communautaire, présence ISTQB/CFTL/conférences.

---

## Recoupement avec l'état réel du dépôt (fait en session, 2026-07-28)

- **Contrat de sortie** : la description Gemini est exacte (D39, `docs/OUTPUT-CONTRACT.md`).
  Écart réel trouvé pendant le recoupement (pas mentionné par Gemini, trouvé en construisant le
  JSON Schema demandé en Phase 1) : `examples/scoring-demo/manifest.json` ne portait pas
  `design.knowledgeApplied`, pourtant documenté comme faisant partie du contrat 1.0 —
  corrigé le jour même (voir D104).
- **`qaia-score` read-only** : exact (D40).
- **Régénération par diff par scénario** : exact, mais Gemini ne cite aucune décision — c'est
  D17 (`docs/DECISIONS.md`).
- **JSON Schema du contrat de sortie, dossier `prompts/adapters/`** : confirmés absents avant
  cette session (`Glob` négatif sur `**/*.schema.json` et `**/adapters/**`) — recommandation
  Phase 1 valide, non dupliquée par le backlog #49-#57 de l'audit Sprint 22. JSON Schema livré
  le jour même (D104). Adapters multi-LLM tracés en issue séparée (voir DECISIONS.md D104).
- **Note de maturité 7,5/10 vs verdict Sprint 22 (2,4/5 ≈ 4,8/10, "non prêt pour une adoption
  pilote sans conditions")** : écart net et non résolu ici. Le rapport Gemini n'a pas eu accès
  à la faille `GET /api/audit` (D99, corrigée le jour de sa découverte, avant ce rapport) ni au
  détail des citations internes cassées (D100-D102) — mais il n'a pas non plus reproduit ces
  défauts pour les découvrir lui-même, contrairement aux 3 sceptiques de l'audit Sprint 22 qui
  ont rejoué des commandes en direct. Les deux audits s'accordent cependant sur le même diagnostic
  de fond : **outillage/preuve d'exécution est le point faible relatif** (6,5/10 chez Gemini ;
  items #51/#52/#53 — benchmark vs prompt direct, moteur k6 réel, démo IA/ML — chez Sprint 22),
  et les deux placent le **mur humain (pilotes réels, #1)** comme la réserve qui empêche de
  clore le verdict à la hausse. Traité comme confirmation croisée sur ce point précis, pas comme
  contradiction.
