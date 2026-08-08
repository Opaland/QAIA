# QA Orchestra exécutée pour de vrai, jugée en aveugle — et elle nous apprend un défaut (2026-08-08)

La dernière case de #70 demandait de faire tourner QA Orchestra **pour de vrai** et de comparer les
sorties, contrat contre contrat. La lecture du 2026-08-08 avait établi ce que leur contrat promet ;
elle ne pouvait rien dire de ce qu'il rend.

## Le protocole, et pourquoi il est construit ainsi

**Je suis leur concurrent.** C'est la raison la moins fiable qui soit de me croire, donc chaque
précaution est là pour retirer ma main du résultat.

| Décision | Pourquoi |
|---|---|
| Entrée **strictement identique** — US-004, story + AC1-AC8 | La section des ambiguïtés plantées a été retirée des deux côtés. C'est exactement ce que QAIA avait reçu. |
| Leur agent joué **verbatim** | `test-scenario-designer.md` suivi à la lettre, avec consigne explicite de **ne pas « améliorer »** leur spécification. |
| Un `context/CONTEXT.md` **écrit pour eux, à leur format** | Leur agent le demande. Les faire tourner sans les aurait handicapés artificiellement. |
| Jugement **en aveugle** | Trois juges à contexte vide voient « A » et « B » sans savoir qui a produit quoi, avec consigne de ne pas chercher à deviner. |
| Trois angles distincts | utilité brute, maintenabilité à six mois, exécutabilité. |
| Compter, pas juger à l'impression | Nombre d'ambiguïtés déclarées, de chemins de refus réellement exercés, nature de la traçabilité. |

Leur agent a produit **34 scénarios**. Le cahier QAIA en compte 38.

## Le verdict : 2 juges sur 3 pour QAIA, 1 pour QA Orchestra

| | Juge 1 (utilité) | Juge 2 (maintenabilité) | Juge 3 (exécutabilité) |
|---|---|---|---|
| **Préférence** | QAIA | QAIA | **QA Orchestra** |
| Ambiguïtés déclarées | 6 vs **9** | 6 vs **9** | 6 vs **9** |
| Chemins de refus exercés | 12 vs **17** | 10 vs **17** | 11 vs **17** |
| Traçabilité | numérotation locale | **identifiant stable** | idem |

Les trois comptages convergent. La divergence porte sur ce qui compte le plus, et le dissident a
un argument que les deux autres n'ont pas réfuté.

## Ce que la mesure retire à notre argumentaire

**La borne à 500,00 € : ils la déclarent aussi.** Les trois juges sont unanimes — aucune des deux
sorties ne tranche en silence. QA Orchestra crée le scénario à 500,00 **et** écrit dans une section
« Risks and Gaps » que la lecture inclusive est une hypothèse à re-baseliner.

L'écart réel est plus étroit que « eux devinent, nous déclarons » : chez eux l'avertissement est à
soixante lignes du scénario et n'est pas lisible par une machine ; chez nous il voyage **avec** le
scénario (`@low-confidence`, renvoi à `Q1`, colonne dans la matrice) et se filtre en une commande.
C'est une supériorité de **structure**, pas de lucidité — et la formuler autrement serait faux.

## Le défaut qu'ils nous trouvent, et qui est réel

Deux juges le relèvent : **le cahier QAIA assère des codes HTTP que l'exigence ne mentionne
jamais.**

Vérifié à la main : les fichiers `.feature` d'US-004 contiennent **17 codes de statut** — deux
`401`, deux `403`, un `404`, cinq `409`, sept `422` — et
`eval/gold-set/US-004-expense-approval.md` **n'en contient aucun**.

C'est précisément la faute que les skills de ce projet interdisent ailleurs. `openapi-ingest`
refuse d'asserter un code non déclaré ; la campagne json-server a ouvert une question ouverte
(`Q4`) plutôt que de deviner, en écrivant que *« les scénarios n'assertent un code que là où le
document promet un comportement observable autrement »*. Le cahier vitrine du projet fait
l'inverse.

Il passe au vert parce que **nous avons aussi écrit l'application** : le système sous test renvoie
les codes que le cahier attend. Une équipe qui implémenterait les mêmes critères avec `400` au lieu
de `422` serait déclarée en défaut par un cahier qui n'en a pas le droit. Ouvert en
[#83](https://github.com/QAIA-Project/QAIA/issues/83).

## Ce que QA Orchestra fait mieux, sans atténuation

**L'exécutabilité, et c'est le motif du seul verdict qui nous est défavorable.** Leur sortie donne
l'URL, la commande de démarrage, la précondition machine, les comptes et le mot de passe, les
données exactes, et une date de référence fixe qui résout « 90 jours » en une date absolue. Un
ingénieur qui ouvre un de leurs scénarios n'a plus aucune décision à prendre.

Le nôtre, pour le même cas, laisse à décider : l'URL de base, l'authentification, ce que « reset to
its seed state » implique, comment on fabrique un justificatif attaché, et quel jour est
« aujourd'hui ».

**Huit classes de risque entièrement absentes de chez nous** : montants nuls et négatifs,
double-clic sur *Submit*, concurrence de deux approbateurs sur le même rapport, retour arrière du
navigateur, justificatif supprimé pendant l'approbation, XSS / Unicode / RTL dans les champs texte,
performance sur 200 lignes, accessibilité clavier et lecteur d'écran.

**Deux ambiguïtés qu'ils nomment et que nous n'avions pas vues** : la remise à zéro des
approbations déjà obtenues après un `changes-requested`, et le fuseau horaire des horodatages
d'audit.

## Ce que QAIA fait mieux

- **17 chemins de refus exercés contre 10 à 12.** Manquent chez eux : toute authentification et
  autorisation transverse (401, IDOR), la re-soumission d'un rapport déjà soumis, l'édition d'un
  rapport soumis. Un juge relève aussi qu'ils traitent « rejet sans commentaire » mais oublient
  « changes-requested sans commentaire », alors que l'AC8 impose les deux.
- **Neuf ambiguïtés contre six, et chacune est *testée***. Chez eux, deux ambiguïtés signalées ne
  sont couvertes par aucun scénario — dont le seuil de 25 € comparé sur le montant converti, où
  leur propre texte écrit « aucun scénario ne couvre ce cas ». Signaler un trou et le laisser
  ouvert vaut moins que le combler avec une hypothèse tracée.
- **Des identifiants stables** qui survivent à la régénération, contre `TS-001..034` qui se décale
  dès qu'on insère un scénario.
- **Une section qui borne son propre périmètre** en disant ce qui n'a pas été généré et pourquoi.
  Leur sortie ne borne jamais la sienne.

## Les limites de cette mesure

- **Une seule de leurs dix skills**, sur un seul ticket, un seul domaine.
- **Leur agent a été joué par le même moteur que QAIA**, dans mon harnais. Ce n'est pas leur
  installation ; c'est leur spécification suivie fidèlement. Un lecteur qui juge cette
  approximation insuffisante a raison de le dire — le protocole est décrit pour qu'il puisse en
  juger.
- **Les juges ne sont pas des humains.** Trois lectures à contexte vide, pas une validation.
- **J'ai conçu le protocole, écrit leur contexte et choisi les axes de jugement.** L'aveuglement
  porte sur le jugement, pas sur la conception de l'épreuve.

## Ce qu'elle change

La lecture du matin disait que leur `smart-test-selector` était un écart en leur faveur. L'épreuve
en ajoute deux autres, plus gênants parce qu'ils portent sur le terrain que QAIA revendique :
**ils rendent une sortie exécutable, et ils couvrent des classes de risque que nous ne couvrons
pas.**

Et elle retire un défaut à leur passif : ils ne devinent pas les bornes ambiguës. Ils les déclarent
— moins bien placées, mais déclarées.

Sortie brute des trois juges : `verdicts.json`. Leur sortie complète : `qa-orchestra-output.md`.
