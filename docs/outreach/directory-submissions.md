# Soumissions aux annuaires — état et textes prêts

Suivi de #69 et #73. Mis à jour le 2026-08-08.

| Annuaire | ★ | État | Action |
|---|---|---|---|
| [jeremylongshore/claude-code-plugins-plus-skills](https://github.com/jeremylongshore/claude-code-plugins-plus-skills) | 2 608 | **PR ouverte — [#1163](https://github.com/jeremylongshore/claude-code-plugins-plus-skills/pull/1163)** | rien à faire, attendre la revue |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | 51 858 | **soumise le 2026-08-08 — [#2466](https://github.com/hesreallyhim/awesome-claude-code/issues/2466), validation automatique passée** | attendre la revue humaine, ne pas relancer |
| QASkills.sh | — | compte à créer | voir #73 |
| claudemarketplaces.com | — | à explorer | |
| claudepluginhub.com | — | à explorer | |
| aitmpl.com | — | à explorer | |
| SkillsMP / ClawHub / skills.sh / Smithery | — | à explorer | |
| [mxschmitt/awesome-playwright](https://github.com/mxschmitt/awesome-playwright) | 1 547 | **PR ouverte — [#177](https://github.com/mxschmitt/awesome-playwright/pull/177)** | attendre |
| [TheJambo/awesome-testing](https://github.com/TheJambo/awesome-testing) | 2 329 | **PR ouverte — [#201](https://github.com/TheJambo/awesome-testing/pull/201)** | attendre |
| [naodeng/awesome-qa-skills](https://github.com/naodeng/awesome-qa-skills) | 151 | **écarté volontairement** | voir §4 |

---

## 4. Les listes de liens — et celle qu'on a écartée

**`mxschmitt/awesome-playwright` — PR [#177](https://github.com/mxschmitt/awesome-playwright/pull/177).**
Section `AI & Agents`, qui ne contenait que **deux** entrées (Playwright Agent CLI et Playwright
MCP, toutes deux officielles). Liste maintenue par un membre de l'équipe Playwright : public
exactement ciblé, et un emplacement non encombré. La PR argumente sur ce qui est
Playwright-pertinent — POM-as-fixtures, locators par rôle, et la suite générée qui tourne en CI
sans session Claude — plutôt que sur QAIA en général.

**`TheJambo/awesome-testing` — PR [#201](https://github.com/TheJambo/awesome-testing/pull/201).**
Section `AI & LLM Testing`, où **QASkills.sh figure déjà**. Liste QA généraliste de référence,
poussée en continu.

Les deux PR déclarent l'état pré-alpha et proposent explicitement au mainteneur de refuser sur
des critères de maturité.

### `naodeng/awesome-qa-skills` : écarté, et le motif compte

151 ★, poussé quotidiennement, et **exactement notre niche** — c'est le candidat qui avait le
meilleur rapport signal/bruit sur le papier.

Mais ce n'est **pas une liste de liens** : contribuer signifie verser une skill complète dans
*leur* structure — `SKILL.md`, `quick-start.md`, `output-formats.md`, `prompts/`, `agents/`,
`evals/`, `references/`. Sept fichiers, leur schéma de métadonnées, leur arborescence. Aucune
section ne permet de simplement lier un projet externe (vérifié : `resources/` ne contient que
`ci-cd`, `examples`, `templates`).

**Ce serait une troisième copie divergente**, après le dépôt QAIA et les copies QASkills. On
vient de passer deux fois par cette dette — `OUTPUT-CONTRACT.md` (#66) et les copies QASkills —
et de la solder à chaque fois en posant un contrôle automatique. Ajouter une troisième variante,
dans un schéma qui n'est pas le nôtre, pour 151 étoiles, c'est rouvrir la dette au pire endroit :
là où le contrôle serait le plus coûteux à écrire.

**À reconsidérer** si leur dépôt ouvre une section de liens externes, ou si QAIA a assez
d'utilisateurs pour que l'effort de synchronisation se justifie.

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

## 2. hesreallyhim/awesome-claude-code — FAIT le 2026-08-08

**51 858 étoiles, poussé quotidiennement. C'est l'annuaire qui compte le plus.**

Soumise : **[issue #2466](https://github.com/hesreallyhim/awesome-claude-code/issues/2466)**,
catégorie `Skills` (leurs 16 catégories n'incluent ni testing ni QA — `Skills` est le seul choix
littéralement exact), **validation automatique passée** le jour même, label `validation-passed`.
En attente de revue humaine, qui est discrétionnaire et sans délai annoncé.

**Ne pas relancer.** Leur `CONTRIBUTING.md` est explicite sur le fait qu'une recommandation ne
crée aucun contrat, et un mainteneur relancé refuse.

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

## 3. QASkills.sh — 7 skills pretes, 5 categories couvertes

**Compte cree le 2026-08-08** (`opaland`). Voie de publication tranchee apres verification de
leur chaine : leur guide documente `@qaskills/skill-validator` (**404 sur npm**),
`npx @qaskills/cli login` (**commande inexistante** en 0.4.1) et `/dashboard/tokens` (**404**).
La seule voie qui fonctionne est l'assistant web du dashboard — et il accepte une URL de
**sous-dossier**, l'etape 2 etant un formulaire manuel et non un parseur. Donc aucun depot dedie
n'est necessaire.

| Copie | Categorie | Etat au 2026-08-08 | Score qualite |
|---|---|---|---|
| `ambiguity-hunt` | E2E | **publiee** | 85/100 |
| `accessibility-audit` | **Accessibility** | **publiee** | **100/100** |
| `security-surface-checks` | **Security** | **publiee** | **100/100** |
| `istqb-technique-selection` | E2E / regression | prete | — |
| `generated-test-self-review` | E2E / API | prete | — |
| `performance-check` | **Performance** | prete | — |
| `visual-regression` | **Visual** | prete | — |

**Moyenne du compte : 95/100** sur trois skills, zero installation — donc portee entierement par
la profondeur de contenu et la fraicheur, les deux seuls criteres de leur formule qui ne
dependent pas d'utilisateurs.

**Le signal a exploiter.** Les deux skills a 100 sont les concretes : outillage nomme, protocoles,
code, cas limites. Celle a 85 est la methodologique. Leur guide dit exactement ca (« sois
specifique et opinione », « inclus des exemples de code », « couvre les cas limites ») et le
bareme le confirme. Pour les quatre restantes, envoyer d'abord `visual-regression` et
`performance-check`, qui ressemblent aux deux gagnantes.

**Rythme volontaire : trois publications le meme jour depuis un compte cree le matin, c'est le
maximum qui ne ressemble pas a du remplissage.** Sur un annuaire cure, l'impression compte autant
que le contenu. Les quatre restantes partent dans quelques jours.

Les quatre dernieres existent parce que les trois premieres tombaient toutes dans la meme zone :
publier trois skills qui se rangent en E2E, c'est occuper une case sur huit de leur navigation
par categorie. Les quatre ajoutees correspondent **au mot pres** a une categorie de leur liste.

Toutes sont surveillees par `eval/tools/check_published_copies.py` : chaque copie enregistre le
sha256 de ses sources, et la CI echoue en nommant la copie a relire des qu'une source bouge.

### Ancien etat

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
