# Second juge LLM indépendant — outillage mainteneur (2026-07-24 ter, suite 5)

Demande fondateur : réduire le risque de monoculture du jugement (le juge LLM du harnais
est toujours Claude, jugeant la sortie d'un Claude générateur). `eval/tools/second_judge.py`
appelle un **modèle d'une autre famille**, via une chaîne de repli 100 % gratuite, sans SDK
(appels HTTP directs — pas de LiteLLM, pas d'API Anthropic, conforme à la demande).

## Portée et frontière (D29 non négociable)

Ceci vit dans `eval/tools/` — **outillage mainteneur, jamais livré aux plugins**. QAIA reste
100 % skill / zéro clé API côté produit ; seul le harnais d'éval du mainteneur, qui n'a jamais
été distribué (comme `structural_score.py`), utilise une clé.

## Chaîne de repli — les 3 maillons vérifiés en live

1. **Gemini** (`GEMINI_API_KEY`) — **testé en live et fonctionnel**.
2. **Groq** (`GROQ_API_KEY`) — **testé en live et fonctionnel**, isolément (Gemini étant
   premier dans la chaîne et déjà fonctionnel, un test du chemin normal ne l'aurait jamais
   exercé) — correct du premier coup, l'API compatible OpenAI de Groq ne réservait pas la
   même surprise que Gemini.
3. **Hugging Face** (`HF_TOKEN`, router "Inference Providers") — **testé en live et
   fonctionnel**.

Secrets dans `.env` (gitignored, jamais commité) ; `.env.example` documente la forme sans
valeurs.

## 2 défauts trouvés et corrigés en le faisant tourner (pas en le relisant)

1. **403** sur l'appel HF via `urllib`, alors qu'un `curl` identique (mêmes headers, même
   body) passait en 200. Cause : le `User-Agent` par défaut d'`urllib` est bloqué par le WAF
   du router HF ; `curl` a un UA différent qui passe. Corrigé en fixant un `User-Agent`
   explicite.
2. **Format de réponse Gemini mal documenté par la doc résumée** (source web) : la page
   citait un champ plat `output_text`, absent en réalité. Le premier appel live a réussi
   (200 OK) mais le parsing plantait — la vraie forme est un tableau `steps[]`, le texte
   vivant dans le dernier step de type `model_output` → `content[0].text`. Corrigé après
   inspection de la vraie réponse, pas de la doc. **Rappel du principe "ne rien prendre au
   pied de la lettre" appliqué à une source tierce, pas seulement à mes propres agents.**

Les deux défauts n'étaient visibles qu'en exécutant réellement le code contre les vraies
API, jamais en relisant le script ou la documentation.

## Preuve de valeur — jugement croisé sur le gold set durci

Prompt envoyé au second juge (gpt-oss-120b via HF, aucun contexte du juge principal) :
juger si le premier scénario de `eval/goldset-hardened/c1-hollow-image.feature` vérifie
quoi que ce soit par lui-même.

> *"The scenario does not verify anything by itself; its assertion [...] requires comparing
> the computed amounts to an external image/table that isn't part of the test data.
> Consequently, the test can only be validated manually against that attachment, not
> automatically."*

**Le second juge, indépendant, détecte le même défaut C1** (AC creux couvert par une image)
que le juge LLM principal et le scoreur déterministe (`structural_score.py`) — convergence
à travers 3 méthodes indépendantes (déterministe, juge Claude, juge tiers). C'est exactement
la preuve de valeur recherchée : un accord inter-juges tri-source, pas juste une plomberie
qui répond.

## Extension — Mistral (fonctionnel) et Cerebras (bloqué côté compte)

- **Mistral** (`mistral-small-latest`) — ajouté et **vérifié en live**, fonctionne du premier
  coup.
- **Cerebras** — ajouté, mais **bloqué**: `GET /v1/models` confirme bien 3 modèles disponibles
  pour la clé (`gemma-4-31b`, `gpt-oss-120b`, `zai-glm-4.7`), mais **les 3 renvoient 402
  Payment Required** à l'appel — un blocage d'activation côté compte Cerebras (l'onglet
  facturation, per le message d'erreur), pas un bug du code. Le repli gracieux fonctionne
  (l'échec est capté, jamais fatal) ; à réactiver si le compte est débloqué côté fondateur.

## Limites honnêtes

- 4 fournisseurs vérifiés en live (Gemini, Groq, HF, Mistral), 1 bloqué côté compte (Cerebras)
  — mais **un seul cas testé** (`c1-hollow-image.feature`) pour la valeur du jugement
  lui-même, pas une campagne de calibration ; à étendre si l'usage se généralise.
- Tous les credentials (HF, Gemini, Groq, Mistral, Cerebras) ont transité en clair dans le
  chat avant leur mise en `.env` — **rotation recommandée côté fondateur** pour tous, non
  faite dans cette session (hors de mon contrôle : je ne peux pas révoquer un credential à sa
  place).
