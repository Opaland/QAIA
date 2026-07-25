# Test A/B sur `qaia` (méta-agent ReAct) — exemples de raisonnement ajoutés vs formulation actuelle

*2026-07-24 ter, suite 7. Suite du prompt management : `qaia` avait été identifié comme le
skill le plus vague du corpus (aucun exemple concret de ce qu'un "bon raisonnement" produit).*

## Méthode

4 états de projet indépendants, du cas trivial (aucun état) au cas dur (3 questions
`[open]` sur des points métier sensibles, utilisateur pressé qui demande à générer quand
même) — même protocole que le test A/B `prioritize` (D52) : deux runs isolés en parallèle,
sans contexte partagé.

- **Variant A** : formulation actuelle (« State your reasoning in one or two sentences »,
  sans exemple).
- **Variant B** : formulation actuelle + 3 exemples de "bonnes" lignes de raisonnement,
  dont un calibré spécifiquement sur le cas dur (questions ouvertes + pression temporelle).

## Résultat — 4/4 états identiques en substance

| État | Variant A | Variant B |
|---|---|---|
| 1 (aucun état, US brute) | us-ingest, raisonnement citant l'absence d'état | identique |
| 2 (extraction validée, compréhension absente) | need-understanding, cite les checkpoints | identique |
| 3 (tout validé jusqu'aux priorités) | testbook-generate, aucune ambiguïté | identique |
| **4 (3 questions ouvertes, utilisateur pressé)** | **refuse de générer aveuglément**, cite Q2/Q5/Q7 par nom et domaine (facturation, autorisation, rétention), propose les deux chemins (résoudre d'abord / générer avec `@low-confidence`), renvoie la décision au testeur | **même qualité**, même spécificité, même structure de réponse |

**Aucune divergence significative** — contrairement au test `prioritize` (D52), qui avait
trouvé un vrai effet de bord. Ici, le garde-fou de persona déjà présent (« you challenge
weak inputs... but the tester always arbitrates ») suffit déjà à produire le bon
comportement sur le cas dur, sans avoir besoin d'un exemple pour le calibrer.

## Décision

**Ne pas appliquer les exemples à `qaia/SKILL.md`.** Pas de gain mesuré = pas de complexité
ajoutée (même principe que "pas de code sans besoin" appliqué à la longueur d'un prompt).
Un skill plus long sans preuve de bénéfice n'est pas neutre : plus de tokens à chaque
invocation, plus de surface à maintenir.

## Ce que ça prouve sur la méthode

Deux tests A/B, deux verdicts différents et tous les deux informatifs :
`prioritize` → l'ajout dégradait (sur-généralisation), rejeté ; `qaia` → l'ajout n'apportait
rien de mesurable, rejeté pour une raison différente (pas de bénéfice, pas de justification
à la complexité). La méthode ne pousse pas systématiquement vers "ajouter un exemple" — elle
mesure, et parfois la formulation existante est déjà suffisante.
