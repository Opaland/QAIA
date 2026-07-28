# perf-check — vrai script k6, run réel (2026-07-28)

**Ferme #52** ("Construire un vrai moteur de charge k6 (même minimal) pour perf-check").
Trouvaille de l'audit externe : `perf-check/SKILL.md` décrivait un menu k6 (load/stress/spike/
soak/scalability) mais aucun script k6 n'existait nulle part dans le dépôt ; la seule
vérification réelle antérieure (`eval/baselines/perf-testability-checks-2026-07-26.md`)
utilisait `curl`, pas k6, et n'exerçait qu'un seul type sur cinq.

## Ce qui a été fait

- `k6` v2.1.0 installé (`winget install k6`, absent avant cette session).
- Script réel : `plugins/qaia-playwright/skills/perf-check/k6/load.js` — type **load** (le
  moins cher, le plus largement applicable, cohérent avec le défaut documenté dans
  `SKILL.md` step 3). Template paramétrable par variables d'env (`BASE_URL`,
  `LATENCY_BUDGET_MS`, `VUS`, `DURATION`) pour rester réutilisable sur une autre cible
  self-hosted sans réécriture (D35).
- Cible : `examples/expense-demo` (SUT réel du dépôt, self-hosted, `node app/server.js`),
  endpoint `GET /api/reports?scope=inbox` (lecture authentifiée, chemin représentatif d'un
  usage réel — un manager consultant sa boîte d'approbation).
- **Exécuté réellement** : `k6 run -e BASE_URL=http://localhost:4599 -e VUS=10 -e DURATION=20s
  load.js` contre le serveur local démarré pour l'occasion (port 4599 pour ne pas entrer en
  conflit avec un port par défaut).

## Résultats mesurés (pas approximés par curl)

| Métrique | Valeur |
|---|---|
| Requêtes totales | 1981 (98,6 req/s) |
| Échecs HTTP | 0,00 % (0/1981) |
| Latence p50 | 574,7 µs |
| Latence p90 | 1,77 ms |
| **Latence p95** | **2,23 ms** (budget testé : < 200 ms — large marge) |
| Latence max | 5,58 ms |
| Seuil `http_req_failed rate<0.01` | ✅ PASS |
| Seuil `inbox_read_latency p(95)<200` | ✅ PASS |

10 VUs constants pendant 20 s, serveur Node in-memory local (pas de réseau externe, D35).
Le budget de 200 ms est délibérément large pour ce SUT de démonstration in-memory — le script
est un gabarit dont un vrai budget de production serait fixé par l'équipe cible, pas une
promesse de performance de QAIA lui-même.

## Limite assumée

Un seul type (load) sur les 5 nommés par le CT-PT menu (D95) a un script réel à ce jour.
Stress/spike/soak/scalability restent décrits en prose dans `SKILL.md` (formes de script
distinctes déjà spécifiées step 3) mais non scriptées — hors périmètre de #52, qui demandait
explicitement "même minimal". Un futur incrément peut reprendre `load.js` comme gabarit pour
les 4 types restants si le fondateur le priorise.
