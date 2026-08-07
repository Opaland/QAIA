# Soumissions aux annuaires — état et textes prêts

Suivi de #69 et #73. Mis à jour le 2026-08-08.

| Annuaire | ★ | État | Action |
|---|---|---|---|
| [jeremylongshore/claude-code-plugins-plus-skills](https://github.com/jeremylongshore/claude-code-plugins-plus-skills) | 2 608 | **PR ouverte — [#1163](https://github.com/jeremylongshore/claude-code-plugins-plus-skills/pull/1163)** | rien à faire, attendre la revue |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | 51 858 | **texte prêt, soumission manuelle obligatoire** | 2 minutes, voir ci-dessous |
| QASkills.sh | — | compte à créer | voir #73 |
| claudemarketplaces.com | — | à explorer | |
| claudepluginhub.com | — | à explorer | |
| aitmpl.com | — | à explorer | |
| SkillsMP / ClawHub / skills.sh / Smithery | — | à explorer | |

---

## 1. jeremylongshore/claude-code-plugins-plus-skills — FAIT

PR [#1163](https://github.com/jeremylongshore/claude-code-plugins-plus-skills/pull/1163), ouverte
le 2026-08-08 depuis le fork `Opaland/`.

Chemin « Path B » que leur `CONTRIBUTING.md` désigne explicitement comme **la voie recommandée
pour les plugins tiers** : une seule entrée ajoutée à `sources.yaml`, `README.md` non touché,
rien de vendorisé. Leur dépôt reste le miroir, le nôtre reste la source de vérité, et une synchro
hebdomadaire (lundis 06:00 UTC) reprend nos pushs.

Entrée soumise : `qaia-core`, `source_path: plugins/qaia-core`, `target_path:
plugins/testing/qaia-core`, MIT, `verified: false`.

La PR déclare l'état pré-alpha en tête, cite les 2,4/5 et 5,0/10, et **propose explicitement au
mainteneur de refuser sur des critères de maturité** — c'est un pari : sur ce genre de dépôt,
une soumission qui annonce ses faiblesses passe mieux qu'une qui les cache et se fait attraper.
Elle signale aussi que `qaia-core` n'a pas de `SKILL.md` racine (c'est un bundle de skills) et
propose deux alternatives si leur catalogue l'exige.

**Si la PR est refusée** : ne pas insister, ne pas rouvrir. Noter le motif dans #73.

---

## 2. hesreallyhim/awesome-claude-code — À FAIRE À LA MAIN (2 minutes)

**51 858 étoiles, poussé quotidiennement. C'est l'annuaire qui compte le plus.**

⚠️ **Ne pas soumettre par l'API.** Leur `CONTRIBUTING.md` est explicite :

> ALL RECOMMENDATIONS MUST BE MADE USING THE WEB UI ISSUE FORM TEMPLATE, OR YOU RISK BEING
> RESTRICTED FROM INTERACTING WITH THIS REPOSITORY TEMPORARILY.

Le risque, c'est ton compte GitHub restreint sur le dépôt le plus visible de l'écosystème. Une
soumission automatisée qui contourne le formulaire ne vaut pas ça. **Cette étape est à cliquer,
pas à scripter.**

**Éligibilité — vérifiée :** leur règle est « ≥ 14 jours depuis le premier commit ET
développement actif » OU « ≥ 100 étoiles ». QAIA : premier commit le 2026-07-23, soit **16 jours**,
avec des commits quasi quotidiens. La première branche passe. ✅

**Une seule ressource à la fois** — ne pas soumettre les quatre plugins.

👉 **[Ouvrir le formulaire](https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml)**

À coller dans les champs :

- **Resource name** : `QAIA`
- **URL** : `https://github.com/QAIA-Project/QAIA`
- **Category** : celle qui correspond le mieux à *tooling / workflows* (le formulaire propose une
  liste ; ne pas forcer une catégorie qui ne colle pas)
- **License** : `MIT`
- **Description** :

```
Claude Code plugins that take a user story to a traceable Gherkin test book — stable
scenario IDs, an acceptance-criterion coverage matrix, and ambiguous criteria surfaced as
open questions rather than silently resolved — then to native Playwright tests. Markdown
skills only: no API key, no MCP server, no hooks, nothing that executes on its own.
Pre-alpha and says so: no human pilot yet, and its own external audit scores (2.4/5, 5.0/10)
are published in the repo.
```

Leur note à lire avant de cliquer, et qui est juste : *« si "être sur la liste" fait partie de ta
stratégie promotionnelle, prévois un plan B »*. La soumission coûte deux minutes et ne doit pas
être attendue comme un levier. Le plan B, ce sont les autres lignes du tableau.

---

## 3. QASkills.sh

Voir #73. Nécessite la création d'un compte, donc le fondateur. Le catalogue accepte les
soumissions tierces (« Publish a Skill », dashboard ou CLI) et il est adossé à The Testing
Academy — 189 000+ abonnés YouTube, c'est-à-dire l'audience QA exacte.

Décision à prendre avant de soumettre : **des skills individuelles** (leur unité, meilleure
découvrabilité, mais QAIA y perd sa cohérence de chaîne) ou **une entrée pointant vers le
marketplace QAIA** (notre unité, plus fidèle, moins bien référencée). Recommandation : commencer
par deux ou trois skills qui tiennent debout seules — `istqb-design`, `us-review`,
`security-surface` — et lier le marketplace depuis leur description.

---

## Règle générale pour les prochains

1. **Une soumission par annuaire, jamais de relance.** Un mainteneur relancé refuse.
2. **Lire le CONTRIBUTING avant, en entier.** Le premier annuaire de cette liste restreint les
   comptes qui contournent son formulaire ; ce n'est probablement pas le seul.
3. **Déclarer l'état pré-alpha dans chaque soumission.** C'est ce qui distingue QAIA du bruit, et
   ça évite le retrait humiliant six semaines plus tard.
4. **Consigner ici** : date, lien, résultat. Y compris les refus, avec leur motif.
