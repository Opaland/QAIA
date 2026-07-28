# QAIA vs. un bon prompt direct à Claude Code (2026-07-28)

**Ferme #51** — identifié par l'audit Sprint 22 comme l'angle le plus menaçant pour la valeur
même du produit, et confirmé priorité n°1 restante par le recoupement de l'audit Gemini (D104).
Ce document rapporte le résultat **honnêtement, y compris ce qui ne va pas dans le sens de
QAIA** (D38 : rappel honnête > fabriqué).

## Méthode

Deux bras, chacun exécuté **à froid, en isolation** (`isolation: "worktree"`, agent dédié),
sur le **même ticket** : `eval/gold-set/US-004-expense-approval.md` (US + 8 AC seulement,
jamais la section "Judge reference — planted ambiguities", réservée à l'évaluateur).

- **Bras QAIA** : un agent suit fidèlement, dans l'ordre, les 6 skills du parcours cœur
  (`us-ingest` → `us-review` → `need-understanding` → `istqb-design` → `testbook-generate` →
  `report`), en mode non-interactif. **Génération neuve, pas la réutilisation de l'artefact
  `examples/expense-demo/` déjà existant et déjà retravaillé au fil de plusieurs sprints** —
  volontairement, pour ne pas comparer un prompt direct à froid contre un QAIA "poli à la main
  sur plusieurs sessions".
- **Bras prompt direct** : un agent reçoit **uniquement** un unique prompt soigné, tel qu'un
  QA lead compétent l'écrirait pour Claude Code sans aucun outillage QAIA (voir le texte complet
  dans `eval/baselines/benchmark-51/direct-arm-clean/`), en une passe, sans itérer sur sa propre
  sortie.
- **Un premier run du bras prompt direct a été rejeté** : l'agent avait lu par erreur (via
  l'outil `Read`, qui n'ignore pas les sections) la section "Judge reference" du fichier
  source, invalidant toute mesure de rappel d'ambiguïté sur ce run (conservé dans
  `direct-arm/` pour trace, non utilisé ci-dessous). **Re-exécuté proprement** en injectant le
  texte de l'US directement dans le prompt de l'agent, sans jamais lui laisser toucher le
  fichier source (`direct-arm-clean/`) — c'est ce second run qui est comparé ci-dessous.
- Coût token lu au niveau orchestrateur (`subagent_tokens` de la notification de fin de tâche),
  pas une auto-déclaration de l'agent (méthode déjà établie, D91).
- Comptages recalculés indépendamment par `eval/tools/structural_score.py` (déterministe, sans
  LLM) et `eval/tools/validate_manifest.py`, jamais pris au mot du rapport de l'agent seul.

## 1. Coût token

| Bras | Tokens réels (aller-retour) |
|---|---|
| QAIA (6 skills, parcours complet) | **133 100** |
| Prompt direct (une passe) | **46 548** |

**QAIA coûte ~2,9× plus de tokens** pour ce ticket. Sans surprise (6 étapes avec checkpoints
contre une seule réponse), mais c'est la première fois que ce ratio est mesuré, pas supposé.

## 2. Volume et ratio négatif

| Bras | Scénarios (recomptés) | Ratio négatif auto-rapporté | Ratio négatif recalculé (déterministe) |
|---|---|---|---|
| QAIA | 51 (50 + 1 `@smoke`) | 45,9 % projeté à l'étape design | **40,0 %** (20/50, gate ADR 0001 : 20/20 conditions `[req-neg]` couvertes — **vérifié**, pas déclaratif) |
| Prompt direct | 52 | ~35–52 % selon la définition (`@negative` seul vs `@negative`+`@edge`) | **36,5 %** (19/52) |

Les deux passent le plancher de 40 % à la marge ou dessus, mais **seul QAIA a un gate vérifié**
(`design.coverage.reqNegCovered/reqNegTotal`, ADR 0001) — le prompt direct n'a que ses propres
tags `@negative`, jamais recoupés contre une liste de conditions négatives requises déclarée en
amont. C'est la différence structurelle, pas le ratio brut lui-même.

## 3. Couverture AC et traçabilité

- **QAIA** : 8/8 AC couverts (vérifié, `coverage-matrix.md` + `manifest.json` validé sans erreur
  par `eval/tools/validate_manifest.py`, D104). Traçabilité par tag `@QAIA-<ID>` + `@AC<n>`.
- **Prompt direct** : 8/8 AC couverts (auto-rapporté, pas de manifeste séparé à valider — le
  prompt direct ne produit qu'un fichier `.feature`, pas d'artefact de traçabilité structuré).
  IDs `EXP-AC<n>-<seq>` + tags `@AC<n>`, mais **aucun tag de technique ISTQB fermé** (`@ep`,
  `@boundary`, etc.) — `structural_score.py` flague chaque scénario des deux bras (QAIA compris
  par endroits) pour ce point, mais QAIA en porte un sur la quasi-totalité de ses scénarios,
  le prompt direct sur aucun.

## 4. Score structurel déterministe (`structural_score.py`, aucun LLM)

| Bras | Fichiers | Score pondéré | Verdicts par fichier |
|---|---|---|---|
| QAIA | 7 `.feature` | **~72/100** (moyenne pondérée par scénario) | 3 PASS (currency-conversion 85, journey 100, lifecycle 91), 2 CONCERNS (authorization 70, line-items 64), **2 FAIL (approval-routing 55, audit-trail 58)** |
| Prompt direct | 1 `.feature` | **47/100** | **FAIL** |

**Résultat honnête, pas un score parfait pour QAIA** : 2 des 7 fichiers du bras QAIA échouent
au gate structurel. Cause identique aux deux : des `Then` de type "récit" plutôt que testables
(`Then the employee's direct manager and finance are both required to approve, in that order`)
— vrai, sans valeur/quote/mot-clé vérifiable, exactement la classe de défaut C1/C2 que ce
scoreur est fait pour attraper (héritage IATS, cas US 676266). **Ce n'est pas un artefact du
scoreur** : ces `Then` sont effectivement moins directement automatisables tels quels qu'un
`Then the approval sequence is ["manager", "finance"]`. Le bras prompt direct souffre du même
défaut de fond, en pire (47 vs 72), plus un marqueur non résolu détecté sur le run contaminé
(non repris ici).

**Redondance (paradoxe du pesticide)** détectée sur les deux bras (groupes de scénarios à
forme Given/When identique, seul le littéral change) — les tests de seuil AC2 (500/5000 €) en
particulier, dans les deux bras. Signal structurel, pas auto-échec (le tool le documente déjà :
un `Then` différent sur une forme identique reste légitime), mais confirme que ni QAIA ni le
prompt direct n'échappent totalement à ce travers sur ce ticket précis.

## 5. Rappel des 4 ambiguïtés plantées (le test le plus dur)

Ni l'un ni l'autre bras n'a vu la section "Judge reference" — seul l'évaluateur la connaît.

| Ambiguïté plantée | QAIA (run à froid) | Prompt direct (run propre) |
|---|---|---|
| Inclusivité exacte du seuil €500/€5000 | ✅ flaggée (`[open]`) | ✅ flaggée explicitement |
| AC3 : "skip to next level" pour un manager > 5000 € | ✅ flaggée (`[open]`) | ✅ flaggée explicitement |
| Interaction AC1×AC7 (changes-requested→draft→rejet) | **⚠ adressée mais résolue comme "answered", jamais posée comme `[open]`/`[low-confidence]`** | ✅ flaggée explicitement |
| AC6 : source de taux + absence de taux (weekend) | ✅ flaggée (`[open]`) | ✅ flaggée (source seule ; le cas weekend/absence spécifique non mentionné) |

**Résultat honnête et inattendu** : sur ce run précis, le **prompt direct égale ou fait
légèrement mieux que QAIA** sur le rappel strict des ambiguïtés plantées — 4/4 explicitement
posées comme ambiguës contre 3/4 clairement `[open]` pour QAIA (le 4ᵉ item a été traité sans
être signalé comme incertain). Ce n'est **pas** ce qu'un précédent run QAIA sur ce même ticket
avait produit : l'artefact déjà existant du dépôt (`examples/expense-demo/qaia-journey/`,
retravaillé au fil de plusieurs sprints antérieurs) avait, lui, posé les 4/4 explicitement
(`synthesis.md`, Q1-Q4). **Variance confirmée d'un run à l'autre** (cohérent avec D62, mode 4 —
la variance de génération est un phénomène déjà documenté, pas nouveau ici) : la force de QAIA
n'est pas qu'un run isolé est infaillible, c'est que son format `[open]`/`[low-confidence]`
rend chaque item **auditable et traçable jusqu'au scénario qui le teste** quand il est bien
posé — contrairement au prompt direct, où le signal existe mais vit uniquement en commentaire
de tête de fichier, sans mécanisme structurel pour vérifier qu'aucun n'a été oublié.

## 6. Fabrication de règles non demandées

Défaut trouvé côté **prompt direct**, absent côté QAIA sur ce run : le prompt direct a
**silencieusement inventé plusieurs règles métier non présentes dans les AC**, listées
honnêtement par l'agent lui-même après coup :
- AC1 : une re-soumission après `changes-requested` redémarre toute la chaîne d'approbation
  depuis le niveau 1 — non dit par les AC.
- AC1 : un rapport ne peut pas être re-soumis sans modification — contrainte inventée.
- AC4 : montant nul ou négatif rejeté — les AC ne parlent que d'un "montant", jamais de signe.
- AC4 : date future invalide — les AC ne bornent que le passé (90 jours), jamais le futur.

Aucune de ces 4 inventions n'est marquée comme hypothèse dans le fichier produit — elles sont
mêlées aux scénarios dérivés directement des AC, indiscernables sans relire le rapport de
l'agent après coup. **C'est le risque concret que le format `[assumption]` de QAIA est conçu
pour éliminer** (chaque hypothèse porte un ID, un défaut proposé, et remonte dans
`openArbitrations` du manifeste — jamais mêlée silencieusement au reste). Le bras QAIA de ce
run n'a fabriqué aucune règle équivalente (vérifié par grep de `[assumption]`/`[open]` dans
`02-understanding.md` contre le contenu du testbook — chaque hypothèse y est tracée).

## Verdict honnête

**Pas une victoire nette pour QAIA, et ce document ne la présente pas comme telle.** Sur ce
ticket, à froid :
- QAIA coûte ~2,9× plus de tokens.
- QAIA structurellement meilleur en moyenne (72 vs 47/100) mais **pas parfait** — 2/7 fichiers
  échouent au gate structurel pour la même classe de défaut (assertions non vérifiables) que
  le prompt direct porte aussi, en pire.
- Sur le rappel strict des ambiguïtés plantées, le prompt direct égale ou dépasse légèrement
  QAIA **sur ce run précis** — la variance de génération de QAIA (déjà documentée, D62) est
  réelle et pas neutralisée par la méthode.
- L'avantage le plus solide et reproductible de QAIA n'est pas "il trouve plus" mais **"ce qu'il
  trouve est vérifiable, gate, et traçable"** : couverture négative auditée contre une liste
  déclarée (ADR 0001) plutôt qu'un tag auto-apposé ; manifeste validé par schema (D104) ; zéro
  règle métier fabriquée et mêlée silencieusement au reste sur ce run, contre 4 chez le prompt
  direct.

**Recommandation honnête pour le positionnement produit** : QAIA ne se défend pas en
prétendant produire plus ou en trouvant systématiquement plus d'ambiguïtés qu'un bon prompt
direct — les deux sont crédibles sur ce point, et ce benchmark ne permet pas de trancher
définitivement en un seul run (limite assumée : N=1 par bras, pas une moyenne sur plusieurs
runs). Le vrai différenciateur mesuré est **la structure et la vérifiabilité** (gate, schema,
traçabilité, discipline anti-fabrication) au prix d'un coût token ~3× plus élevé — c'est cette
proposition de valeur précise, pas "plus de couverture", qui doit être mise en avant.

## Limites assumées

- **N=1 par bras.** Un seul run chacun ; la variance documentée (D62, et le point 5 ci-dessus)
  signifie que ce résultat précis ne doit pas être généralisé sans plusieurs runs. Un futur
  incrément (si le fondateur le priorise) répéterait 3× chaque bras pour une vraie mesure de
  variance, pas un point unique.
- Le bras QAIA suit fidèlement les `SKILL.md` mais sans le mécanisme d'installation Skill
  natif de Claude Code (les skills ne sont pas "installées" dans l'agent délégué au sens du
  marketplace) — même méthodologie que les mesures de budget token existantes (D91), pas un
  nouveau biais introduit ici.
- Un seul ticket (US-004, finance/RH). Pas de généralisation multi-domaine dans ce document.

## Fichiers

- `eval/baselines/benchmark-51/qaia-arm/` — artefacts complets du bras QAIA (checkpoints,
  testbooks, manifest).
- `eval/baselines/benchmark-51/direct-arm-clean/` — sortie du bras prompt direct (run propre,
  utilisé pour toutes les comparaisons ci-dessus).
- `eval/baselines/benchmark-51/direct-arm/` — premier run contaminé, conservé pour trace,
  **non utilisé** dans les comparaisons.
