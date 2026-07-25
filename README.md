# QAIA — Agentic QA platform, open source

> 🇫🇷 [Version française ci-dessous](#-français)

**Status: pre-alpha.** Core (`qaia-core` 0.2.6), automation (`qaia-playwright` 0.1.1) and scoring (`qaia-score` 0.1.0) plugins exist and validate; not yet proven by real pilots. See [`docs/STATUS.md`](docs/STATUS.md) for the honest state and what's next.

QAIA turns user stories into prioritized, traceable **Gherkin test books** and then into **native Playwright tests** — distributed as **skills and plugins** that run inside *your* Claude session. No API key, no backend, no data leaves your session beyond what you already send to Claude.

Built with and for testers: ISTQB techniques applied and justified, requirement→test traceability designed for **regulated environments** (medical software first), and a conversational workflow where the tester validates every step.

## Honest positioning (read this first)

- **Runs on your Claude subscription.** Every generation consumes your own session quota. Indicative cost per command is published per plugin, measured on our gold set.
- **"Learning" means local knowledge.** The feedback mode enriches a versioned, file-based knowledge base (`.qaia/knowledge/`) in your repo — there is no model training and no central server.
- **Claude Code first, portable by design.** The core (US → test book) is written as portable skills; automation (Playwright) requires Claude Code + Playwright MCP.
- **Web-first automation.** Mobile coverage means browser emulation, not native iOS/Android.

## What v1 will do

1. Ingest a user story (file, URL, Jira) — you validate the source
2. Verify extraction, reformulate the need, surface ambiguities
3. Build a shared, git-versioned project knowledge base
4. Apply and justify ISTQB test design techniques (Foundation + Test Analyst)
5. Prioritize by risk — the tool proposes, the human arbitrates
6. Generate an **atomic Gherkin test book** with stable scenario IDs (`@QAIA-xxx`), a requirement coverage matrix, and a ≥40 % negative/boundary scenario ratio
7. Export (`.feature` + XLSX/Markdown), report, and **regenerate by scenario-level diff** when the US evolves — your manual edits are preserved
8. Learn from your corrections (validated promotion of recurring feedback into rules)

Then: native Playwright automation (E2E, API, mobile-web), and perf / security / accessibility plugins.

## Repository map

| Path | Content |
|---|---|
| [`PROMPT.md`](PROMPT.md) | Founding prompt (vision, constraints, user journey) |
| [`docs/DISCOVERY.md`](docs/DISCOVERY.md) | Discovery v2: 3 gates, 88 questions, 12 hard objections |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | 41 acted decisions + 17 technical defaults |
| [`docs/DELIVERY.md`](docs/DELIVERY.md) | Roadmap M0→M5, plugin architecture |
| [`docs/KANBAN.md`](docs/KANBAN.md) | Board structure + prioritized backlog |
| [`docs/STATUS.md`](docs/STATUS.md) | **Honest project state + resume prompt** (start here to continue) |
| [`docs/M0-CHECKLIST.md`](docs/M0-CHECKLIST.md) | M0 progress and pending owner actions |
| [`docs/PILOT-KIT.md`](docs/PILOT-KIT.md) | 15-minute guided walkthrough for pilot testers |
| [`plugins/qaia-core/`](plugins/qaia-core/) | Core plugin: US → prioritized Gherkin test book (15 skills, incl. oracle-generate + report) |
| [`plugins/qaia-playwright/`](plugins/qaia-playwright/) | Automation plugin: test book → native Playwright + CI pipeline (E2E/API/a11y/perf/security) |
| [`plugins/qaia-score/`](plugins/qaia-score/) | Scoring plugin (read-only): 10-dimension rubric (/20) + PASS/CONCERNS/FAIL/WAIVED gate |
| [`docs/OUTPUT-CONTRACT.md`](docs/OUTPUT-CONTRACT.md) | Standardized run manifest every plugin shares (D39) |
| [`eval/`](eval/) | Evaluation harness: gold set + rubric + scored baselines + robustness campaign |
| [`examples/medibook/`](examples/medibook/) | Worked end-to-end example: real app + POM Playwright automation (24 tests green) |
| [`examples/oracle-demo/`](examples/oracle-demo/) | Standards as test-case generators (Luhn oracle, computationally verified) |
| [`examples/scoring-demo/`](examples/scoring-demo/) | Output contract + qaia-score walk-through (manifest, scorecard, gate) |
| [`examples/rag-demo/`](examples/rag-demo/) | The RAG in use: a knowledge base breaking the recall ceiling on a thin US (D38) |
| [`examples/jira-demo/`](examples/jira-demo/) | Jira connector: a REST v3 issue export → validated QAIA capture (D9, #9) |
| [`docs/DEMO-TARGETS.md`](docs/DEMO-TARGETS.md) | Vetted catalog of demo/practice apps to exercise QAIA on |

## Contributing

Contributions are welcome — read [`CONTRIBUTING.md`](CONTRIBUTING.md) first. Every PR requires a DCO sign-off; PRs touching skills additionally require a traced adversarial agent review (skills are prompts: a malicious instruction is invisible to linters). Security reports: see [`SECURITY.md`](SECURITY.md).

License: [MIT](LICENSE).

---

## 🇫🇷 Français

**Statut : pré-alpha (jalon M0 — fondations).** Rien n'est encore installable pour un usage réel.

QAIA transforme des user stories en **cahiers de test Gherkin** priorisés et traçables, puis en **tests Playwright natifs** — distribués en **skills et plugins** qui s'exécutent dans *votre* session Claude. Pas de clé API, pas de backend : aucune donnée ne quitte votre session au-delà de ce que vous envoyez déjà à Claude.

Construit avec et pour les testeurs : techniques ISTQB appliquées et justifiées, traçabilité exigence→test pensée pour les **environnements réglementés** (logiciel médical d'abord), et un mode conversationnel où le testeur valide chaque étape.

**Positionnement honnête** : l'outil consomme votre quota d'abonnement Claude (un coût indicatif par commande est publié par plugin, mesuré sur notre gold set) ; « l'apprentissage » = enrichissement d'une base de connaissance locale versionnée dans votre repo (pas d'entraînement de modèle) ; cœur portable en skills, automatisation via Claude Code + Playwright MCP ; mobile = émulation navigateur (web-first).

Le parcours v1 : ingestion validée de l'US → contrôle d'extraction → compréhension du besoin → RAG d'équipe versionné git → techniques ISTQB justifiées → priorisation par risque arbitrée → cahier Gherkin atomique (IDs stables, matrice de couverture, ≥ 40 % de scénarios négatifs) → exports `.feature` + XLSX/Markdown → **régénération par diff sans perdre vos retouches** → feedback promu en règles après validation. Ensuite : automatisation Playwright native (E2E, API, mobile-web) et plugins perf / sécurité / accessibilité.

Contribuer : lire [`CONTRIBUTING.md`](CONTRIBUTING.md) (DCO obligatoire, revue adversariale par agent pour toute PR touchant un plugin). Signalements de sécurité : voir [`SECURITY.md`](SECURITY.md). Licence [MIT](LICENSE).
