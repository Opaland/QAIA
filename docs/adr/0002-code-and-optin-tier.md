# ADR 0002 — Un peu de code, et un tier opt-in pour hooks/MCP/agents

- **Statut :** accepté (demande du fondateur, 2026-07-24 : « prends le meilleur d'IATS » +
  « tu peux faire un peu de Python et mettre des MCP, des hooks, des commands, des agents »)
- **Révise :** D14 (qui interdisait hooks/MCP/agents dans les plugins)
- **Contexte :** la lecture de la doc IATS réelle montre que ses meilleures parties (score
  **déterministe**, sniffer anti-fabrication, observabilité + budget cappé, robustesse fail-closed,
  agents ReAct) reposent sur du **code**. QAIA, distribué en **skills Markdown à un public inconnu**,
  s'était interdit tout code auto-exécuté (leçon fondatrice #2 : le public inconnu exécute avec ses
  propres permissions).

## Décision

On **prend le meilleur d'IATS** sans trahir la leçon #2, en distinguant deux natures de code :

### 1. Python *en session*, généré par un skill — AUTORISÉ et encouragé
Un skill peut **matérialiser et exécuter un script jetable** dans la session de l'utilisateur
(avec ses permissions, sous ses yeux), puis le jeter. C'est ainsi qu'on obtient le **déterminisme
d'IATS** (score structurel reproductible, sniffer) **sans shipper de code** : le plugin reste
100% Markdown. Même modèle que la génération des tests Playwright. Rien n'auto-exécute à
l'installation ; le garde-fou supply-chain (pas de `hooks/`, `agents/`, `.mcp.json` **dans les
plugins**) reste **intact**.

### 2. Hooks / MCP / agents — TIER OPT-IN séparé, jamais dans le cœur
Ceux-là **auto-exécutent du code** dans l'environnement de l'installeur. Les distribuer à un
public inconnu par défaut = l'erreur exacte que D14 prévenait. Donc :

- ils vivent dans un **tier opt-in explicitement séparé** (paquet/marketplace distinct, jamais
  installé par `qaia-core`/`qaia-playwright`/`qaia-score`) ;
- chaque composant subit la **revue adversariale tracée** de `CONTRIBUTING.md` (diff traité comme
  données non fiables, sans réseau ni write), résumé posté avant merge ;
- il est **désactivé par défaut**, documenté « ce que ce code exécute chez toi », et **jamais un
  prérequis** du cœur ;
- il n'arrive **qu'après** que le cœur soit éprouvé sur pilote (leçon #2 + issue #23).

### 3. Commands (slash) — AUTORISÉES (déjà le cas)
Une command est un **prompt** (ex. `session-review.md`). Aucun code auto-exécuté → pas de risque
de distribution. On peut en ajouter librement.

## Conséquences

- Le déterministe (score, sniffer, détecteurs C1/C2) se livre **maintenant** en skill (Python en
  session). Cf. `eval/tools/structural_score.py` (preuve) et `testbook-score` step 0.
- Les « best of IATS » qui exigent de l'auto-exécution — **hook budget/observabilité** (issue #7,
  la régression FinOps), **MCP connecteur** (Tuleap/Jira temps réel), **agent revue ReAct** — sont
  tracés comme **tier opt-in**, post-pilote, revus en adversarial. Ils ne polluent pas le cœur.
- La matrice de portabilité (D29) tient : le cœur reste utilisable en skills seules ; le tier
  opt-in est un bonus Claude Code, jamais un prérequis.

## Ce qu'on NE fait pas

- On ne met **pas** de hook/MCP/agent dans `plugins/qaia-*` (CI continue de le bloquer).
- On ne rend **pas** le déterminisme dépendant d'un binaire installé — il est généré en session.
- On ne construit pas le tier opt-in **avant** le pilote du cœur (sinon on répète la leçon #2).
