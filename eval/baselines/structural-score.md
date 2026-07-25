# Score structurel déterministe — preuve de discrimination (2026-07-24)

Grounds issues #26 (score déterministe ≠ juge LLM), #27 (sniffer anti-fabrication), #28
(cas sans résultat attendu). Algorithme de référence : `eval/tools/structural_score.py`
(**outillage mainteneur, non distribué** — cf. « distribution 100% skill » plus bas).
**Aucun LLM, aucun réseau** → rejouable à l'identique.

## Gold set durci

`eval/goldset-hardened/` — un cas conforme + 4 défauts reproduisant les modes d'échec
**documentés** du cas réel US 676266 (100/100 machine vs 58/100 humain). Fixtures **fabriquées
délibérément** pour prouver que le détecteur les attrape (ce ne sont pas des « données
fantaisie » : ce sont des fixtures de test du scoreur, assumées comme telles).

## Résultat

Batch reproductible : `python3 eval/tools/structural_score.py --batch eval/goldset-hardened`

| Fixture | Défaut visé | Score /100 | Gate | Ce qui est détecté |
|---|---|---|---|---|
| `good.feature` | (aucun) | **100** | **PASS** | — |
| `c1-hollow-image.feature` | **C1** — AC « couvert » par une image | **85** | **FAIL** | AC creux → STOP forcé (score haut ≠ bon test) |
| `c2-no-expected.feature` | **C2** — cas sans résultat attendu | **70** | **FAIL** | `Then` non-vérifiable → STOP forcé |
| `fabrication.feature` | **#27** — données inventées | **75** | CONCERNS | markers seuls (pas de source → sniffer inactif) |
| `truncated.feature` | cohérence — steps tronqués | **80** | CONCERNS | step tronqué (PASS plafonné à CONCERNS) |
| `redundant.feature` | **mode 3b (#24)** — paradoxe du pesticide | **91** | PASS (signal) | 3 scénarios au même Given/When (seul l'âge change), aucune nouvelle partition testée → pénalité -9, jamais de STOP forcé |
| `tag-conformant.feature` | (aucun) — tags priorité/technique/négatif corrects | **100** | PASS | `tag_audit` vide (0 violation), ratio négatif **recalculé indépendamment** = 33,3 % (1/3) |

Sniffer actif (avec source) : `... fabrication.feature --source eval/goldset-hardened/_source.md`
→ **60 / FAIL** (3 littéraux techniques non traçables + 2 markers, ≥3 hits = STOP).

## Détecteur de redondance (#24 mode 3b, ajouté 2026-07-24)

Groupe les scénarios par la forme normalisée (littéraux → `<val>`/`<num>`) de leurs seuls
`Given`/`When` (le `Then` est exclu de la clé exprès : une assertion réellement différente sur
un `Given`/`When` identique reste signalée, pas blanchie — à un humain de trancher si c'est une
vraie règle par valeur ou un copier-coller). **Signal, jamais un STOP forcé** : contrairement à
C1/C2/sniffer, la redondance seule ne peut pas être fabriquée avec certitude par regex — un faux
positif (bornes réellement distinctes) coûterait plus cher qu'un faux négatif ici. Pénalité
plafonnée à -15 (-3/scénario redondant au-delà du premier du groupe).

## Défaut trouvé et corrigé sur le scoreur lui-même (comparaison multi-modèles, 2026-07-24 ter)

En comparant Claude à Gemini/Groq/Hugging Face sur le même ticket (`eval/baselines/
multimodel-generation-comparison.md`), le run Hugging Face place son commentaire
`# Condition: ...` **entre** les tags et la ligne `Scenario:` — une convention différente de
celle utilisée jusqu'ici. Le parseur effaçait alors les tags en attente (la ligne de reset
s'appliquait à toute ligne non-tag non-Scenario, y compris les commentaires), faisant tomber
la traçabilité de 25/25 à 0,9/25 et le score de 72/CONCERNS à 48/FAIL — **une pénalité de
mise en forme, pas un vrai défaut de contenu**. Corrigé (le reset ignore désormais les lignes
de commentaire) ; 0 régression sur les 7 fixtures de `eval/goldset-hardened/`. Pertinent pour
`testbook-validate`, qui doit noter des cahiers non générés par QAIA — cette convention
alternative aurait pu y fausser un audit externe en silence.

## Défaut trouvé et corrigé sur le scoreur lui-même (#24, 2026-07-24)

En passant le scoreur sur du contenu **réel généré** (pas les fixtures fabriquées) — cf.
`gap-harness-24.md` — le détecteur C1 a fait un **faux positif** : `HOLLOW_RE` déclenchait sur
toute présence du mot "image" (ex. `Then the group picture should be the default image`, une
assertion parfaitement vérifiable), pas seulement sur une délégation à une preuve externe
("voir le tableau en annexe"). Corrigé : `HOLLOW_RE` exige désormais un **marqueur de
délégation** (voir/see/cf./conforme à/correspond à…) immédiatement avant le nom de l'artefact —
les 5 fixtures existantes restent inchangées (même score, même gate), et le faux positif sur le
cas réel disparaît (FAIL forcé → CONCERNS, cohérent avec le contenu). Preuve que le harnais de
gap (#24) trouve des défauts **dans l'outillage mainteneur lui-même**, pas seulement dans les
skills produit.

## Ce que ça prouve

1. **Un score structurel élevé n'immunise pas** : `c1` (80) et `c2` (70) ont une belle structure
   mais **échouent au gate** via STOP forcé — reproduction fidèle de « le 100 machine masque un
   test creux ». C'est la contre-mesure directe du cas 676266.
2. **Le déterminisme discrimine sans juge LLM** : mêmes entrées → mêmes scores, à l'identique.
   C'est ce qui manquait à `qaia-score` (juge LLM ±15-20 pts).
3. **Le sniffer (#27) marche — avec une nuance honnête** : pleinement efficace **seulement avec
   une source/oracle** à comparer. Sans source, `fabrication` ne tombe qu'en CONCERNS (via les
   markers `[À DÉFINIR]`/`TODO`), pas en FAIL. **Conséquence produit** : le pass anti-fabrication
   doit être branché sur la source US / l'oracle cité, pas tourner à vide.

## Distribution — 100% skill (contrainte fondatrice)

Ce scoreur Python **n'est pas** livré aux installeurs (QAIA se distribue en **skills Markdown**,
zéro code auto-exécuté — garde-fou supply-chain). Il vit dans `eval/` comme **preuve mainteneur**.
Côté produit, le déterminisme se distribue ainsi :

- **En Claude Code** : le skill porte l'**algorithme mécanique** (barème 4 dims, détecteurs
  marker/sniffer/C1/C2/troncature, règle STOP) et **matérialise+exécute un script jetable en
  session** → déterminisme réel, script jamais shippé (même modèle que la génération Playwright).
- **Sur une surface sans exécution** : dégradation honnête — Claude exécute l'algorithme
  pas-à-pas (reproductible « par construction du prompt », moins que du code, dit comme tel).
- Le **juge LLM reste une couche sémantique séparée** — jamais confondu avec le score déterministe
  (deux nombres distincts ; le gate de publication s'appuie sur le déterministe).

## Limites

- Détecteurs **heuristiques** (regex FR/EN) — un `Then` vérifiable formulé exotiquement peut passer
  au travers ; à élargir avec le corpus réel du #24.
- Le gold set durci ici est **fabriqué** (5 fixtures). La validation sur **vraies US dures** (gold
  set ~88 US, confidentiel) reste à faire **en local** (#24) — non versionnable dans ce repo public.

## Correctif VAGUE_RE/HOLLOW_RE (2026-07-25, D65, suite au corpus élargi #24 profondeur)

Le corpus élargi 24 cas (D58-D64, `eval/baselines/corpus-24-depth.md`) a trouvé 3 formulations
paraphrasées qui évadaient `VAGUE_RE`/`HOLLOW_RE` — un `Then` restait non détecté malgré une
absence réelle de valeur/état concret asserté :

1. **C5 (lot 3, Mistral)** : `Then the tie is broken by a deterministic rule (e.g.,
   lexicographical order of player names)` — aucun mot-clé de la liste fermée d'origine
   (correct/as expected/properly/…) ne matchait.
2. **C18 (lot 6, Groq)** : `Then the total refund amount is the sum of refunds for the
   cancelled lines` / `Then the refund amount for the line is the full amount` — restitution
   circulaire d'une formule, pas de chiffre.
3. **C10 (lot 4, Groq)** : `Then the row order is exactly as drawn` — à l'examen après
   correctif, ce cas **n'est en fait pas un vrai défaut du détecteur** : le scénario complet
   contient des lignes `And` suivantes qui asserte des valeurs concrètes (`the first row is
   "Continue Watching"`, etc.) — la règle `hollow` exige à raison que **toutes** les lignes
   `Then`/`And` d'un scénario soient creuses pour déclencher C1, et c'est le cas ici : le bloc
   entier reste vérifiable. Le vrai souci était stylistique (une phrase d'intro paresseuse
   rachetée par les lignes suivantes), pas un score/gate faux. Noté honnêtement plutôt que
   compté comme un 3e bug corrigé.

**Correctif appliqué** (`eval/tools/structural_score.py`) : `VAGUE_RE` étendu avec
`deterministic rule`, `consistent`/`cohérent`, `appropriately`/`appropriée(ment)`, et le
motif circulaire `is/est (the/le) sum/somme/total/full amount/montant complet` ; `HOLLOW_RE`
étendu avec les déférences autoréférentielles `as drawn/configured/specified/documented/
described/illustrated/written` (sans nom d'objet requis après, contrairement au motif
d'origine qui exigeait `tableau/image/maquette`).

**Vérifié sans régression** : les 7 fixtures existantes (`eval/goldset-hardened/*.feature`)
produisent des scores et findings **identiques** avant/après (diff vide). Sur 15 fichiers
`.feature` réels générés pendant le corpus élargi (scratchpad de session, jamais commités),
**seuls les 2 cas ciblés (C5-Mistral, C18-Groq) basculent** de PASS/CONCERNS silencieux vers
FAIL avec un finding `vague/non-verifiable Then (C2)` nommé — aucun autre fichier n'a changé
de score ou de gate. Nouvelle fixture de régression : `eval/goldset-hardened/paraphrased-vague.feature`
(4 scénarios : 2 paraphrases-vagues du corpus réel qui doivent FAIL, 1 assertion concrète qui
doit rester PASS, 1 scénario config-driven `@low-confidence` légitime qui **ne doit jamais**
être flagué vague — un hedge correct sur une valeur externe non spécifiée n'est pas le même
défaut qu'une restitution de formule sans chiffre).

**Limite résiduelle assumée, non corrigée** : un second `Then` du cas C5 (Mistral) —
`Then the order between "P1" and "P2" is consistent (e.g., by player name)` — contient des
valeurs entre guillemets (les identifiants de joueurs), ce qui déclenche `ASSERT_RE` (qui
matche tout littéral entre guillemets sans distinguer un nom d'entité déjà connu d'une valeur
de résultat réellement asserté) et masque le nouveau match `VAGUE_RE` sur "consistent". Ce
n'est pas un défaut du fix ajouté ici mais une limite préexistante d'`ASSERT_RE` (trop
permissif sur les guillemets) — non traité dans ce correctif, à reprendre si un futur cas du
corpus la reproduit.

## Correctif de la limite résiduelle ci-dessus (2026-07-25, issue #31, P3)

La limite D65/D71 ci-dessus est corrigée : `structural_score.py` ajoute `has_strict_assertion()`,
une variante resserrée d'`ASSERT_RE` qui n'accorde une valeur de résultat concrète à un littéral
entre guillemets que s'il est **immédiatement adjacent à un verbe d'état/assertion**
(`is/are/est/sont/shows/displays/equals/contains/returns/redirects`…) — un identifiant cité en
passant dans une phrase sans rapport (`between "P1" and "P2"`) ne compte plus. Un digit **à
l'intérieur** d'un littérale cité (le `1` de `"P1"`) est également neutralisé (les segments entre
guillemets sont effacés avant le test du `\d` nu), sinon la règle numérique nue rouvrait la même
faille par un autre chemin.

**Vérifié sur le cas C5 exact** : `the order between "P1" and "P2" is consistent (e.g., by
player name)`, testé isolément, bascule maintenant en `vague/non-verifiable Then (C2)` → gate
`FAIL`, `forced_stop: true` (auparavant : `PASS`/`score 100`, aucun finding). Fixture de
régression permanente ajoutée : scénario 5 de
`eval/goldset-hardened/paraphrased-vague.feature` (`@QAIA-BILL-005`), reprenant le libellé exact
du second `Then` de C5. Score du fichier : 78 → **76**/FAIL (5 scénarios au lieu de 4, gate
inchangé), avec le nouveau scénario listé dans le finding `vague/non-verifiable Then (C2)`.

**Décision de conception, documentée honnêtement (compromis assumé)** : `has_strict_assertion()`
n'est branchée que dans le calcul de `vague` (C2), **pas** dans `ASSERT_RE`/`covers()` qui reste
inchangée. Un premier essai de resserrement direct d'`ASSERT_RE` elle-même (donc aussi dans
`covers()`) a été testé et **rejeté** : il fait basculer ~15 assertions légitimes et déjà
publiées à "aucun signal concret" dans des fixtures réelles non fabriquées —
`eval/concerns-zone-fixtures/{m1,m2,m3,m4}-*/booking.feature` (ex. `the slot with "Dr. Ben
Osei" is not listed`, `only slots ... "Dermatology" ... are shown`), `eval/baselines/
multi-judge-median-testbook/booking.feature` (ex. `the confirmation shows the practitioner name
"Dr. Alia Novak"`) et `eval/baselines/rag-recall-gain/run-a.feature` — une régression réelle sans
contrepartie, puisqu'aucune de ces lignes ne déclenche par ailleurs `VAGUE_RE` (le seul contexte
où la permissivité des guillemets nus pose un vrai problème). Le fix reste donc **partiel par
construction** : il ferme le trou C2 documenté sans toucher au calcul de `completeness`/`covers()`
ailleurs ; un identifiant cité entre guillemets juxtaposé à un mot `VAGUE_RE` dans une formulation
non anticipée par `has_strict_assertion()` pourrait encore passer au travers — non revendiqué
comme exhaustif.

**Vérifié sans régression (2026-07-25)** : les 8 fixtures de `eval/goldset-hardened/*.feature`
(les 7 originales + `paraphrased-vague.feature`, désormais 5 scénarios) produisent des scores,
gates et findings **strictement identiques** avant/après pour les 7 fixtures inchangées ; seule
`paraphrased-vague.feature` change, et uniquement à cause du 5ème scénario ajouté exprès (78 →
76, toujours FAIL). Vérifié également, au-delà du périmètre strict de la mission, sur les 8
autres fichiers `.feature` du dépôt qui ne sont pas dans `eval/goldset-hardened/`
(`eval/concerns-zone-fixtures/{m1,m2,m3,m4}-*/booking.feature`, `eval/baselines/
multi-judge-median-testbook/{booking,cancellation}.feature`, `eval/baselines/
rag-recall-gain/run-{a,b}.feature`) : **score, gate et findings identiques avant/après sur les 8**
— ces fixtures ne sont pas des baselines documentées de `structural_score.py` (elles servent à
d'autres expériences, cf. `eval/baselines/concerns-zone-calibration.md`), mais la stabilité totale
observée confirme que le correctif ne déborde pas de son périmètre voulu.
