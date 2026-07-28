# Adapter multi-LLM — premier run réel contre Gemini/Groq/Mistral (2026-07-28)

**Ferme #58** ("Dossier prompts/adapters/ pour la portabilité multi-LLM des instructions").
Cible choisie : **Gemini** plutôt que le OpenAI GPT-4o suggéré par l'issue — pas de clé OpenAI
disponible dans `.env`, alors qu'une clé Gemini fonctionnelle existe déjà (utilisée par
`eval/tools/second_judge.py` depuis D51) ; choix pragmatique cohérent avec l'infra réelle du
dépôt, et pertinent puisque c'est le fournisseur qui a produit l'audit externe à l'origine de
cette issue.

## Ce qui a été fait

- `prompts/adapters/gemini/testbook-generate.md` : reformulation du cœur de règles de
  `plugins/qaia-core/skills/testbook-generate/SKILL.md` (technique ISTQB par AC, plancher ≥40%
  de négatifs, traçabilité, gestion d'ambiguïté) selon les 3 recommandations Partie 2 de
  l'audit Gemini : sections `CRITICAL_RULE_N` au lieu de balises pseudo-XML, un exemple
  few-shot complet, chain-of-thought explicite en 2 étapes (analyse puis génération).
- Exécuté réellement via `eval/tools/multi_model_generate.py` (outil existant, non modifié)
  contre le ticket réel `eval/gold-set/US-004-expense-approval.md` (US + 8 AC uniquement,
  jamais la section "Judge reference" — même règle que le benchmark #51).
- **3/5 fournisseurs répondent** : Gemini, Groq, Mistral. Hugging Face et Cerebras échouent
  (`402 Payment Required`) — problème pré-existant documenté (#32, crédit HF épuisé ;
  Cerebras jamais activé côté facturation), pas un défaut de l'adapter.

## Résultat Gemini (cible principale de l'issue)

**Auto-rapporté (Step 1 du CoT) :** 22 scénarios projetés, ratio négatif projeté 45,4 %.
**Réellement livré (Step 2, compté indépendamment) :** **25 scénarios** — écart entre le
compte projeté et le compte réel (confirme une fois de plus D50 : le ratio auto-rapporté par
un LLM n'est pas fiable, y compris en amont de la génération, pas seulement après coup).

**Vérifié par le scoreur structurel déterministe** (`eval/tools/structural_score.py`, aucun
LLM, `eval/baselines/benchmark-58/gemini.feature`) :

| Métrique | Valeur |
|---|---|
| Scénarios comptés | 25 |
| Ratio négatif recalculé | **40,0 %** (exactement au plancher — l'auto-évaluation à 45,4 % était optimiste) |
| Score structurel | **60/100 — CONCERNS** |
| Redondance (paradoxe du pesticide) | **2 groupes quasi-dupliqués détectés** : les 4 scénarios de seuil AC2 partagent une forme Given/When identique (seule la valeur littérale change) ; les 2 scénarios AC3 (manager/directeur) idem |
| `traceability` (sous-score du tool) | 0,0 — anomalie non expliquée : chaque scénario porte pourtant un tag `@AC<n>` et un ID stable `US-004-AC<n>-<seq>` ; suspecté format de tag non reconnu par le détecteur du scoreur plutôt qu'une vraie absence de traçabilité. **Non résolu ici, signalé honnêtement** — nécessite un suivi séparé sur `structural_score.py` lui-même avant de blâmer la sortie Gemini sur ce point précis. |

**Défaut de contenu réel trouvé (pas un artefact d'outillage)** : pour résoudre l'ambiguïté
"un directeur soumettant un rapport > 5000 €", Gemini invente un rôle **"Executive Board"**
qui n'existe nulle part dans les 8 AC ni dans la hiérarchie `manager < finance < director`
qu'elles décrivent — une fabrication, pas juste une interprétation.

**Recoupement avec les 4 ambiguïtés plantées** (`eval/gold-set/US-004-expense-approval.md`,
section réservée à l'évaluateur, jamais donnée au modèle) :

| Ambiguïté plantée | Gemini l'a-t-il repérée ? |
|---|---|
| Inclusivité du seuil €500/€5000 exact | **Non** — la banque B est traitée comme incluant les deux bornes sans jamais signaler que c'est un choix, alors que le texte source ("under €500" vs "€500–€5000") laisse la question explicitement ouverte |
| AC3 : "skip to next level" pour un manager > 5000 € | **Non** — jamais testé sur ce cas précis ; à la place, Gemini a inventé et flaggé une ambiguïté voisine mais différente (directeur > 5000 €), en fabriquant un rôle inexistant pour la résoudre |
| Interaction AC1×AC7 (changes-requested→draft→reject) | **Non** — jamais mentionnée |
| AC6 : source de taux / absence de taux (weekend) | **Oui** — repérée et flaggée explicitement comme non spécifiée |

**Score : 1/4 ambiguïtés plantées correctement repérées**, 1 fabrication de rôle inexistant,
1 écart entre le ratio négatif auto-rapporté et le ratio réel. Comparer à QAIA sur le même
ticket : 4/4 ambiguïtés plantées repérées (`examples/expense-demo/qaia-journey/testbooks/US-004/synthesis.md`,
Q1/Q2/Q3/Q4 recoupent exactement les 4 items plantés), 0 fabrication de rôle, ratio négatif
gate-vérifié (17/17 conditions négatives requises couvertes, ADR 0001) plutôt qu'auto-rapporté
comme seul signal.

## Résultats secondaires (Groq, Mistral) — analyse plus légère

| Fournisseur | Scénarios (approx., grep) | Tags `@negative` | Tags `@low-confidence` | Note |
|---|---|---|---|---|
| Groq | 11 | 4 | 1 | Réponse complète (se termine par une phrase de conclusion, pas tronquée) mais nettement plus courte que Gemini — couverture par AC plus clairsemée |
| Mistral | 19 | 9 | 6 | Réponse arrêtée à exactement 10 000 caractères — **plafond de longueur de l'API suspecté, pas confirmé** ; le dernier scénario visible semble complet mais la couverture totale (AC restantes) ne peut pas être garantie exhaustive |

Non audités au même niveau de détail que Gemini (hors périmètre raisonnable de ce premier run,
qui visait explicitement Gemini par l'issue #58) — bruts, conservés pour référence future si
quelqu'un veut étendre l'adapter à ces fournisseurs.

## Verdict honnête (D38, D50)

L'adapter **fonctionne** au sens technique : un prompt reformulé selon les recommandations de
l'audit Gemini produit bien un test book Gherkin structuré, taggé, avec un ratio négatif qui
atteint le plancher de 40 %. Mais le résultat est **mitigé sur le fond**, pas une victoire nette
pour la portabilité multi-LLM : 1 ambiguïté plantée sur 4 repérée (vs 4/4 pour QAIA sur le même
ticket), 1 fabrication de rôle non demandé, ratio auto-rapporté optimiste par rapport au ratio
réel recalculé. Cohérent avec le diagnostic déjà connu du corpus 24 cas (D58-D64) : les
fournisseurs non-Claude tiennent la forme mécanique (tags, ratio, structure) mais restent moins
fiables sur le raisonnement multi-règles profond et la détection d'ambiguïté fine — un adapter
mieux formulé aide sur la forme, pas sur ce fond-là.

## Fichiers

- `prompts/adapters/gemini/testbook-generate.md` — l'adapter lui-même.
- `eval/baselines/benchmark-58/prompt.txt` — prompt complet envoyé (adapter + AC US-004).
- `eval/baselines/benchmark-58/{gemini,groq,mistral}.txt` — réponses brutes.
- `eval/baselines/benchmark-58/gemini.feature` — bloc Gherkin extrait, scoré par
  `structural_score.py`.
