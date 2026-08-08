# ADR 0006 — QAIA doit tourner dans l'agent que l'utilisateur a déjà

- Statut : **Accepté**
- Date : 2026-08-08
- Décidé par : le fondateur, arbitrage explicite

## Contexte, et la contradiction qui n'en était pas une

La question « est-ce qu'on est multi-LLM ? » avait été présentée comme **incompatible** avec la
contrainte d'autonomie : livrer du multi-LLM, c'était livrer des clés API vers plusieurs
fournisseurs, donc dépendre de ressources tierces au runtime.

**C'était une mauvaise lecture de la demande.** Ce que le fondateur veut dire est différent :

> le projet peut être lancé sous Claude, ChatGPT, Gemini…

C'est-à-dire : **les skills tournent dans l'agent que l'utilisateur possède et paie déjà**. Aucune
clé n'est livrée. Aucun service n'est appelé par nous. La contrainte d'autonomie n'est pas violée —
elle est **étendue** : aujourd'hui on ne dépend d'aucune clé, demain on ne dépend d'aucun hôte non
plus.

C'est la suite logique de l'argument « zéro clé API », pas son contraire.

## État réel, mesuré

| | |
|---|---|
| Les **skills** passées sur plusieurs modèles | Claude, Gemini, Groq, Hugging Face — juillet 2026, `eval/baselines/multimodel-skill-sweep.md` |
| Le **produit** essayé sur un autre agent que Claude Code | **jamais. Zéro test.** |

La distinction est celle qui compte : on a vérifié que les *instructions* survivent à un changement
de **modèle**. On n'a jamais vérifié qu'elles survivent à un changement d'**hôte** — format de
paquet, mécanisme d'invocation, accès aux fichiers, conventions de sortie.

Et le dépôt revendique déjà la portabilité : *« 100 % Markdown »*, *« aucune clé »*. **Une promesse
jamais éprouvée.**

## Décision

**La portabilité multi-agent devient un objectif produit**, avec un ordre imposé :

1. **Mesurer d'abord.** Prendre la chaîne existante et l'exécuter dans un autre agent, telle
   quelle. Ce qui casse est le vrai backlog ; tout ce qu'on construirait avant cette mesure serait
   une supposition.
2. **Corriger ce qui est mesuré**, pas ce qu'on imagine.
3. **Ne packager qu'ensuite.** Un format de distribution portable n'a de sens que si le contenu
   l'est déjà.

## Ce qui reste interdit

La contrainte d'autonomie ne bouge pas : **aucune clé API livrée, aucun backend, aucun composant
auto-exécuté**, et [le garde-fou de la chaîne d'approvisionnement](../../CONTRIBUTING.md) continue
de bloquer hooks, agents et serveurs MCP dans les plugins. Rendre les skills portables ne doit
introduire ni exécutable, ni service.

## Ce à quoi il faut s'attendre

Les skills sont du Markdown, mais elles ne sont pas neutres : elles nomment le format de plugin
Claude Code, ses commandes d'installation, sa disposition `skills/`, et supposent un agent qui lit
et écrit des fichiers. **La partie difficile n'est pas le contenu, c'est tout ce qui l'entoure** —
et on n'en connaît l'ampleur qu'après la première mesure.

Un concurrent a déjà résolu ce problème : `npx @qaskills/cli add <skill>`, avec détection
automatique de l'agent, 27+ agents supportés. La méthode est publique et bonne. Ce n'est pas une
raison de copier leur contenu ; c'en est une de ne pas réinventer leur mécanisme d'installation.

## Le risque, écrit maintenant

Chaque agent supplémentaire est une surface de plus à **prouver**, et le projet n'a toujours aucun
utilisateur sur le premier. Le garde-fou tenu : **on ne déclare jamais un hôte qu'on n'a pas
essayé.** Une case cochée sans exécution est précisément le défaut que ce dépôt a passé la journée
du 2026-08-08 à traquer.
