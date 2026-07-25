# RAG-in-use — gain de rappel mesuré (issue #19, D38)

*2026-07-25. L'éval vérité-terrain (`eval/baselines/groundtruth-training.md`) a établi un
plafond structurel de rappel (~47-53 % selon le run) porté par le comportement config-driven :
D38 interdit d'inventer une valeur pilotée par une config externe non fournie et impose de la
flaguer en gap plutôt que de la deviner. Le mécanisme prévu pour lever ce plafond (`rag-build`
+ le protocole de récupération/citation, `plugins/qaia-core/skills/README.md` section
"Knowledge retrieval & citation", illustré — mais jamais chiffré — dans `examples/rag-demo/`)
n'avait jamais été mesuré. Ce document chiffre le gain sur un cas neuf, exécuté réellement (pas
une projection illustrative comme `examples/rag-demo/conditions.md`).*

## Méthode

Un seul cas (N=1), domaine neuf (réservation de cours en salle de sport — "FitFlow"), jamais
utilisé dans le corpus élargi 24 cas (`eval/goldset-hardened/corpus-24-plan.md` : Fintech,
Logistique, Santé, EdTech, Gaming, IoT, HR-tech, Voyage, Immobilier, Média, DevOps — pas de
fitness/réservation-de-créneaux). Ticket clean-room, terse, sans liste d'AC explicite (même
protocole "ticket dur" que le corpus 24).

1. **Run A** — `us-ingest` → `us-review` (extraction) → `need-understanding` (prérequis de
   `istqb-design`, exécuté car sans lui `istqb-design` n'a pas de `02-understanding.md` à lire)
   → `istqb-design`, **sans `knowledge/`**. `prioritize` exécuté au minimum (tags P1/P2/P3
   seulement) pour satisfaire le prérequis de `testbook-generate`, hors-sujet ici. Mode
   non-interactif : chaque point ⚠ VALIDATION est enregistré `simulated: <défaut appliqué>`
   (règle 3 du contrat partagé), aucune vraie session utilisateur.
2. **`knowledge/`** monté à la main (5 règles métier réalistes, cf. ci-dessous) — écrit
   indépendamment du ticket, comme le ferait une vraie base d'équipe déjà en place, **pas** les
   réponses attendues du juge.
3. **Run B** — mêmes skills, **avec `knowledge/`**, protocole de citation `# rule: BR-KB-nnn`
   suivi à la lettre (`istqb-design` step 3d, et `need-understanding` step 8/re-hunt puisque ce
   skill charge aussi l'index de connaissance en tête de ses étapes).
4. **Jugement indépendant** : un sous-agent frais (aucun contexte de génération, comme l'exige
   le rituel de release `eval/README.md`) reçoit uniquement le ticket, `knowledge/
   business-rules.md` et les deux `.feature` — décompose chaque règle en comportements testables
   distincts, compte la couverture dans chaque run, et cherche toute fabrication.

Tous les artefacts réels sont commités dans `eval/baselines/rag-recall-gain/` :
`us.md`, `knowledge/index.md`, `knowledge/business-rules.md`, `run-a-journey.md` +
`run-a.feature`, `run-b-journey.md` + `run-b.feature`.

## Le cas — FIT-118

Ticket thin (voir `rag-recall-gain/us.md`) : "As a studio member, I want to book a spot in a
fitness class and manage my booking... Booking uses membership credits" — aucun chiffre nulle
part. 3 AC extraites (booking, cancel, waitlist). Aucune mention de coût en crédits, de délai
d'annulation, de conséquence d'un no-show, ni du mécanisme de promotion de liste d'attente —
exactement la famille de gap D38 cible.

## Run A — sans base de connaissance

`istqb-design` (steps 1-3c) dérive **16 conditions** (9 `[req-neg]`, ratio négatif 56.25 %,
au-dessus du seuil 40 % sans padding) : EP/decision-table sur AC1 (réservation, capacité,
doublon, auth), state-transition sur AC2 (annulation, IDOR, double-annulation, classe déjà
passée), state-transition/decision-table sur AC3 (liste d'attente, doublon). Détail dans
`rag-recall-gain/run-a-journey.md` et `run-a.feature`.

**4 gaps honnêtement flagués, pas inventés** (step 3c ceiling clause) :

| Gap | Question qui reste sans réponse |
|---|---|
| GAP-A1 | Coût exact en crédits par cours, variation selon créneau/palier d'abonnement |
| GAP-A2 | Délai d'annulation gratuite avant le cours (seuil, pénalité au-delà) |
| GAP-A3 | Conséquence d'un no-show |
| GAP-A4 | Mécanisme et timing de promotion de la liste d'attente |

`knowledgeApplied: []` — enregistré comme "knowledge base absent" (règle 8 du contrat partagé),
zéro littéral config-driven inventé dans `run-a.feature` (confirmé par le juge indépendant,
section suivante).

## Run B — avec `knowledge/`

Base montée pour l'occasion (`rag-recall-gain/knowledge/business-rules.md`), 5 règles :
`BR-KB-201` (coût en crédits standard=1/pic=2), `BR-KB-202` (annulation gratuite ≥4h, sinon
1 crédit perdu, no-show = 2 crédits perdus), `BR-KB-203` (quotas par palier : Basic 8/mois sans
report, Premium 20/mois report plafonné à 10, Unlimited illimité mais 1 réservation active/jour),
`BR-KB-204` (promotion de liste d'attente : FIFO, auto si ≥2h avant le cours, sinon offre
manuelle avec fenêtre de confirmation de 15 min), `BR-KB-205` (3 no-shows en 30 jours →
restriction de réservation de 7 jours).

Effet sur `need-understanding` : 4 des 8 questions de Run A (Q1-Q4, toutes `[out-of-slice]`)
passent au statut **répondu, cité** ; Q5 (FIFO, un `[assumption]`) devient une règle confirmée.
3 questions (Q6-Q8, hors du périmètre de cette base) restent inchangées — la base ferme ce
qu'elle couvre, pas tout.

`istqb-design` step 3d dérive **13 conditions nettes supplémentaires** (+1 confirmation Q5
non comptée dans le chiffre, pour ne pas gonfler artificiellement le delta) réparties sur les
16 conditions de base : AC1 +6 (coût par créneau, quota Basic épuisé, plafond de report Premium,
cap quotidien Unlimited, restriction no-show active), AC2 +4 (borne 4h, pénalité no-show,
déclenchement de la restriction 3-en-30-jours), AC3 +3 (auto-promotion ≥2h, fenêtre 15 min,
cascade au membre suivant si la fenêtre expire). Les **4 gaps de Run A sont tous fermés**, un
par un, chaque condition citant sa règle :

| Gap (Run A) | Fermé par | Conditions |
|---|---|---|
| GAP-A1 (coût crédits) | `BR-KB-201`, `BR-KB-203` | 5 |
| GAP-A2 (délai d'annulation) | `BR-KB-202` | 2 |
| GAP-A3 (conséquence no-show) | `BR-KB-202`, `BR-KB-205` | 3 |
| GAP-A4 (mécanisme liste d'attente) | `BR-KB-204` | 3 |

Ratio négatif du testbook complet (Run A + Run B) : 12 blocs `@negative` / 28 blocs = **42.9 %**
— reste au-dessus du seuil 40 % sans qu'aucun cas n'ait été ajouté pour le gonfler (3 des 12
blocs neufs sont négatifs ; les pénalités de crédit et la cascade de promotion ne sont **pas**
`@negative` au sens strict D20 — aucune requête n'y est refusée, c'est un effet de bord ou un
timeout passif, pas un refus).

## Jugement indépendant (sous-agent frais, sans contexte de génération)

Décomposition indépendante des 5 règles en **19 comportements testables distincts** (chaque
paire entrée→sortie compte séparément, ex. "≥4h gratuit" et "<4h pénalité 1 crédit" = 2
comportements de `BR-KB-202`). Résultat :

| | Comportements couverts | Rappel |
|---|---|---|
| **Run A** (sans RAG) | 0 / 19 | **0 %** |
| **Run B** (avec RAG) | 15 / 19 | **79 %** |

**Delta chiffré : +15 comportements config-driven couverts sur 19 (+79 points de rappel de
classe A), sur ce cas.** Zéro fabrication trouvée dans `run-a.feature` ni dans `run-b.feature`
— chaque littéral de Run B (crédits, heures, minutes, seuils) trace exactement à
`knowledge/business-rules.md` ; aucun n'est halluciné au-delà de ce que la base fournit.

### Défaut trouvé — la RAG elle-même n'atteint pas 100 %, même sur une règle citée

Le juge a identifié un résidu réel, pas du bruit : sur `BR-KB-203` (quotas par palier), **4 des
7 comportements distincts ne sont réalisés par aucune scène, même en Run B** — l'octroi mensuel
de base de chaque palier (Basic 8, Premium 20) et la propriété qualitative "pas de report"
(Basic) / "illimité" (Unlimited) ne sont jamais assertés ; seuls le plafond de report (11→10+1)
et le cap quotidien Unlimited sont couverts. Autrement dit : `istqb-design` step 3d, même avec
la règle sous les yeux et citée, ne dérive pas systématiquement **toutes** les sous-clauses d'une
règle qui en empile plusieurs dans un même paragraphe — il semble prioriser les cas-limites
(boundary) "intéressants" au détriment des faits de base plus plats. C'est un vrai gap de
génération, distinct du plafond D38 (qui concerne l'absence de connaissance, pas
l'exploitation incomplète d'une connaissance présente) — à signaler pour une future décision :
`istqb-design` step 3d pourrait avoir besoin d'un rappel explicite "une règle à plusieurs
sous-clauses (table, énumération) exige une condition par sous-clause, pas seulement pour la
sous-clause la plus digne d'un test de borne".

**Défaut mineur corrigé pendant la revue** : l'en-tête de `run-b.feature` annonçait "12
conditions nettes" alors que 13 tags `# condition:` existent réellement (017-027, hors
confirmation 028) — écart d'un, corrigé après la relecture du juge (voir le commentaire de
correction dans le fichier). Une scène (`AC3-C6` "l'offre expire, passe au suivant") avait aussi
été taguée `@negative` à tort (rien n'y est refusé pour Jordan, c'est un timeout passif, pas un
refus au sens strict D20) — retiré, et la condition reçoit son propre ID (`AC3-C8`) plutôt que
de partager celui d'`AC3-C6`, pour ne pas fausser la traçabilité condition→scénario.

## Réserve de bruit du juge — N=1, pas une moyenne

Ce delta (+79 points de rappel de classe A, 0 %→79 %) est mesuré **une seule fois**, un seul
juge, un seul cas. `eval/baselines/groundtruth-training.md` a déjà établi qu'un juge LLM
jugeant la même paire (US, testbook) dans des sessions indépendantes varie de **±15-20 points**
de rappel (ex. G03 87 %↔47 %, G22 100 %↔67 %). Deux réserves supplémentaires spécifiques à cette
mesure :

- **Asymétrie du signal, pas juste du bruit.** Le 0 % de Run A n'est pas un artefact de mesure :
  c'est une conséquence **déterministe** du protocole (la ceiling clause D38 interdit
  structurellement d'inventer un littéral config-driven), pas une variable aléatoire — un
  deuxième juge indépendant retrouverait très probablement aussi 0/19 sur Run A (il n'y a
  littéralement aucune valeur config-driven dans le fichier à créditer). Le vrai bruit porte
  surtout sur le score de Run B (79 % pourrait légitimement osciller entre ~60 % et ~95 % selon
  la granularité de décomposition d'un juge différent — le résidu `BR-KB-203` ci-dessus montre
  déjà qu'un compte plus strict existe).
- **Le juge décompose lui-même les "comportements distincts"** — un choix de granularité
  discrétionnaire (ex. traiter "report ≤10" et "report >10 forfeited" comme 1 ou 2
  comportements change le dénominateur). Le 19 n'est donc pas un total canonique ; un N plus
  large avec plusieurs juges indépendants serait nécessaire pour un chiffre publiable comme
  moyenne — ce que ce document ne prétend pas être.

**Conclusion sur le bruit** : le sens et l'ordre de grandeur du gain (plafond structurel proche
de 0 % → gain massif, majoritaire mais pas total) sont robustes ; le chiffre "79 %" précis ne
doit pas être cité comme une constante du système, seulement comme "large et > 0" sur ce cas.

## Verdict

Le mécanisme RAG existant (`rag-build` + protocole de citation `istqb-design` 3d) **fonctionne
et ferme le plafond D38 mesurément**, sur ce premier cas chiffré (contrairement à
`examples/rag-demo/`, qui n'était qu'illustratif) : 4/4 gaps honnêtement flagués en Run A sont
fermés en Run B, zéro fabrication introduite par le mécanisme lui-même, ratio négatif D20
préservé sans padding. Le gain n'est pas parfait — un résidu mesuré (`BR-KB-203`, 4/7
comportements manqués même avec la règle citée) montre que "citer une règle" ne garantit pas
d'épuiser toutes ses sous-clauses, un axe d'amélioration distinct et plus fin que le plafond
D38 lui-même. Rappel honnête (0 % structurel, gaps flagués) plutôt que fabriqué : confirmé sur
ce cas des deux côtés de la comparaison.
