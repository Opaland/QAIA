# Relecture à contexte vide du travail d'une journée : 19 constats sur 30 survivent (2026-08-08)

Tout ce qui a été livré le 2026-08-08 l'a été par un seul auteur, dans une seule session. La règle
la plus dure du projet — *aucun producteur ne note sa propre sortie* — s'appliquait donc à personne
ce jour-là, alors qu'une vérification avait déjà attrapé cet auteur **neuf fois** dans la même
journée.

Cinq lentilles, **aucun contexte préalable**, chacune sur un périmètre distinct : la campagne
externe, la page publique, les cinq skills du jour, tous les chiffres affirmés, et la cohérence
entre le registre de décisions et le dépôt réel. Chaque constat a ensuite été **attaqué par un
sceptique chargé de le détruire**, avec consigne explicite de refuser en cas de doute — le coût
d'un faux constat publié étant supérieur à celui d'un vrai constat manqué.

**30 constats examinés, 11 réfutés, 19 confirmés.** Sortie brute : `panel-raw.json`.

## Le constat matériel : la procédure de reproduction publiée était fausse

Les scénarios `@QAIA-EXT-031` et `@QAIA-EXT-032` interrogent `/foo?a.b=bar` et `/foo?arr[0]=bar`.
Le README de la cible **documente ces deux promesses en les illustrant avec `/foo`**, mais ne
fournit aucune ressource `foo` dans sa base d'exemple.

La base réellement utilisée était donc enrichie — ce que le cahier déclarait bien dans ses `Given`,
mais que ni le rapport ni le bilan ne disaient. Pire :

- le bilan affirmait *« la base utilisée est celle publiée dans le README, recopiée telle quelle »* ;
- la section « Reproduire » ordonnait *« avec la base d'exemple du README »* et promettait
  *« attendu : 3 rouges »* ;
- **aucun `db.json` n'était archivé dans le dépôt.**

**Un tiers suivant la page obtenait 5 rouges, pas 3.** La campagne dont tout l'argument est
« vérifiable par n'importe qui » n'était pas reproductible.

Le sceptique chargé de détruire ce constat l'a **renforcé** : il a trouvé, dans un fichier de trace
que le constat ne citait pas, que `/foo` avait répondu un tableau vide plutôt qu'un 404 — preuve
directe que la collection existait bien dans la base utilisée.

Corrigé : base archivée sous `db.used.json`, procédure et bilan rectifiés, avec la mention de ce
qu'ils disaient avant. **Et la correction a été rejouée** — 29 verts / 3 rouges avec la base
archivée, 27 verts / 5 rouges avec celle du README seul. La prédiction du panel était exacte au
test près.

## Le motif commun aux dix-huit autres

Tous, sans exception, relèvent de la même chose : **un chiffre ou une affirmation écrits de
mémoire, jamais recroisés avec le dépôt.**

| Constat | Réel |
|---|---|
| Quatre valeurs pour le nombre de skills, dans quatre documents du même jour | 30, 32, 33, 35 — **la vraie est 35** |
| Un `74k-star` survivant dans une skill après la correction du matin | 75 694 |
| Colonne « sur-sélection » de la lecture naïve à `0` | la mesure donne **2** |
| « Les deux documents ont été produits » | seul le bilan existe ; **la moitié « plan » n'a jamais servi** |
| « Deux questions ouvertes résolues par l'exécution » | l'en-tête du cahier dit *« NONE is resolved »* |
| « La base recopiée telle quelle » | enrichie d'une collection |
| Page publique : *« l'endpoint n'a rien fait »* | le post **était** supprimé ; seuls les dépendants survivaient |
| Page de comparaison : « 30 skills » | 35 |
| `D154` à `D157` absentes du registre | **le défaut corrigé deux heures plus tôt, immédiatement reproduit** |

La dernière ligne est la plus instructive. Le matin, sept décisions étiquetées dans des messages de
commit et absentes de `DECISIONS.md` avaient été trouvées et comblées, avec un commit expliquant
que *« les messages de commit ne sont pas la mémoire du projet »*. **Quatre heures plus tard, quatre
décisions de plus étaient dans exactement le même état.**

## Ce que les onze réfutations disent aussi

Un tiers des constats n'a pas survécu, et c'est le signe que le sceptique faisait son travail. Le
plus intéressant : un constat reprochait au bilan d'attribuer un correctif « au mainteneur » alors
qu'il avait été écrit par un contributeur. Le sceptique a montré que **la campagne elle-même nomme
cet auteur deux fois ailleurs**, avec son ticket — l'imprécision était réelle mais déjà consignée,
et la corriger était une affaire d'un mot, pas un défaut publiable.

Elle a été corrigée quand même.

## Ce que cette relecture ne prouve pas

- **Ce ne sont toujours pas des humains.** Cinq lentilles automatiques ne remplacent pas un lecteur.
  Ce panel est une lecture hostile bien construite, pas une validation externe, et l'appeler
  autrement serait la surenchère exacte que le dépôt reproche déjà à ses propres pages.
- **Le panel a été conçu, lancé et interprété par l'auteur du travail relu.** Il ne pouvait pas
  contester ce qu'aucune lentille ne regardait — le choix des périmètres est resté celui du
  producteur.
- **Les 19 constats ont été vérifiés à la main avant correction**, et chacun l'a été. Mais c'est
  encore le même auteur qui a jugé.

## Ce qu'elle prouve

Qu'après une journée passée à traquer les affirmations non vérifiées, un auteur en avait laissé
**dix-neuf** derrière lui — dont une qui rendait sa preuve la plus solide non reproductible, et une
qui répétait à l'identique un défaut qu'il venait de corriger.

C'est l'argument le plus concret que ce dépôt puisse produire pour sa propre règle 3 : non pas que
la relecture croisée soit une bonne pratique, mais qu'**elle attrape ce que la vigilance seule ne
rattrape pas**.
