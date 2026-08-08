# Sélection des tests depuis un diff : l'heuristique naïve rate 6 impacts sur 10

L'issue #76 le disait avant d'écrire la moindre ligne : relier un diff à des tests sans données de
couverture est de l'**heuristique**, et une skill qui affirme « ces 12 tests couvrent ce
changement » sans pouvoir le prouver ment avec assurance.

Alors l'heuristique a été mesurée avant d'être écrite.

## Protocole

Falsifiable, et c'est tout l'intérêt :

1. Choisir un fichier réel de `examples/expense-demo` — `tests/pages/LoginPage.js`, dont la méthode
   `signIn` a été modifiée le jour même pour un tout autre motif
2. **Prédire** les tests impactés depuis le diff seul, sans exécuter quoi que ce soit
3. **Casser réellement** ce fichier — `password.fill(password)` remplacé par une valeur fixe
4. Lancer **toute** la suite, 56 tests, 4 projets
5. Ce qui tombe est la vérité terrain. La prédiction s'y confronte.

Deux lectures ont été prédites, pas une : la naïve et la transitive.

## La chaîne de dépendance, et le maillon que la lecture naïve saute

```
fichier de test  →  fixtures.js  →  page objects  →  application
```

Un test qui **ne nomme jamais** `LoginPage` en dépend pourtant, à travers une fixture. Dans
`examples/expense-demo`, `fixtures.js` construit `LoginPage` et appelle `signIn` dans les fixtures
`employee`, `manager`, `finance`, `director` et `openActor`.

| Lecture | Ce qu'elle prédit | Combien |
|---|---|---|
| Naïve — les specs qui écrivent `LoginPage` | `visual.expense.spec.js` | 6 tests |
| Transitive — plus ce que les fixtures construisent | visual + e2e + a11y | 13 tests |

## Vérité terrain

Suite complète avec la faute injectée : **56 tests, 10 échecs.**

| Projet | Verts | Échecs |
|---|---|---|
| `api` | **43** | **0** |
| `e2e-desktop` | 0 | **5** |
| `a11y` | 1 | **1** |
| `visual` | 2 | **4** |

Les 43 tests d'API n'utilisent que la fixture `request` : aucun ne touche `LoginPage`, aucun n'est
tombé. La prédiction ne les avait pas sélectionnés.

## Le résultat

| Lecture | Prédits | Tombés | **Ratés** | Sur-sélectionnés | Rappel | Précision |
|---|---|---|---|---|---|---|
| Naïve | 6 | 10 | **6** | 0 | 40 % | 100 % |
| Transitive | 13 | 10 | **0** | 3 | **100 %** | 77 % |

**Lire la colonne « Ratés ».** La lecture naïve manque 6 impacts sur 10 : les cinq tests e2e et un
test d'accessibilité, dont **aucun n'écrit `LoginPage` nulle part**. Ils y accèdent par les
fixtures `employee` et `openActor`.

Une équipe qui aurait fait confiance à cette lecture pour ne rejouer que 6 tests aurait sauté
exactement ceux qui cassaient.

## Les trois sur-sélections, et pourquoi elles sont explicables

La lecture transitive prédit 13 et 10 tombent. Les trois écarts ne sont pas du bruit :

- `@QAIA-VIS-001` (écran de connexion) — ne se connecte jamais, photographie l'écran vierge
- `@QAIA-VIS-002` (identifiant rejeté) — appelle bien `signIn`, mais avec un **mauvais** mot de
  passe. La faute injectée remplace le mot de passe par une autre valeur fausse : le message
  d'erreur attendu s'affiche quand même, le test passe
- `@QAIA-A11Y-US004-001` — audite la page de connexion elle-même, avant toute authentification

Chacune est une dépendance **réelle** dont l'issue observable ne change pas sous cette faute-là.
Une sur-sélection explicable n'est pas une erreur de la méthode : c'est le prix du rappel.

## Ce que la mesure fixe comme règle

**Le rappel est la métrique à protéger, pas la précision.** Une sur-sélection coûte des secondes de
CI. Un raté coûte un défaut livré — et la confiance qui faisait utiliser l'outil.

D'où la position de la skill : en cas de doute, sur-sélectionner. Et quand le fichier modifié est
une fixture, une configuration ou un utilitaire partagé, le rayon d'action est la suite entière —
la réponse honnête est « tout rejouer », pas une liste qui a l'air précise.

## Limites

- **Un seul changement, sur un seul dépôt.** Un fichier, une faute, une suite de 56 tests. Rien ici
  ne dit ce que donne la méthode sur un dépôt de 5 000 tests ou sur un changement qui touche
  plusieurs couches.
- **La faute injectée est grossière.** Un mot de passe faux casse franchement. Un changement subtil
  — un délai, un ordre — impacterait probablement moins de tests, et la sur-sélection paraîtrait
  plus grande.
- **Aucune donnée de couverture.** Toute cette mesure porte sur le mode *hypothèse* de la skill.
  Le mode *fondé*, avec une vraie instrumentation, n'est pas mesuré ici.
- **La vérité terrain, c'est ce qui tombe sous cette faute-là.** Un test peut dépendre du fichier
  changé et rester vert — les trois sur-sélections en sont la preuve. « Impacté » et « tombe » ne
  sont pas la même chose, et le tableau mesure le second.

## Reproduire

```bash
cd examples/expense-demo/app && node server.js &        # SUT sur :4500
cd ../tests
# remplacer dans pages/LoginPage.js :
#   await this.password.fill(password);
# par :
#   await this.password.fill("faute-injectee");
npx playwright test          # attendu : 56 tests, 10 echecs, 43 api verts
git checkout pages/LoginPage.js
npx playwright test          # attendu : 56 verts
```
