# LinkedIn — post court (FR)

> Prêt à coller. Post de fil, pas article : sur LinkedIn le post court porte beaucoup plus loin
> que l'article long, et l'article sert de destination pour ceux qui veulent creuser.
> **Ne pas mettre le lien dans le post lui-même** — LinkedIn dégrade la portée des posts sortants.
> Mettre le lien en **premier commentaire**, immédiatement après publication, et éditer le post
> pour ajouter « lien en commentaire ».
>
> Meilleur créneau pour une audience QA francophone : mardi/mercredi/jeudi, 8h-9h ou 12h-13h.

---

## Version A — l'angle qui a le plus de chances de marcher

**Hook : on ne publie jamais ses mauvaises notes. Alors publions-les.**

```
J'ai fait auditer mon projet open source par un panel de 13 personas.

Note moyenne : 2,4 sur 5.
Verdict : « prototype d'ingénierie avancé, non prêt pour une adoption pilote ».

Une revue d'architecture séparée lui a mis 5,0 sur 10.

J'ai tout publié dans le dépôt.

Pas par masochisme. Parce que je construis un outil de QA, et qu'un outil de QA
qui cacherait ses propres résultats défavorables serait une plaisanterie.

QAIA prend une user story et en sort un cahier de test Gherkin tracé, puis des
tests Playwright exécutables. Ce sont des skills Markdown pour Claude Code :
pas de clé API, pas de backend, rien qui s'installe dans votre dépôt et qui
s'exécute tout seul.

Ce qui est prouvé, et vérifiable en cinq minutes sans rien installer :
→ une suite générée tourne sur un runner GitHub Actions sans session Claude,
  sans skill chargée — 8 tests, 8 verts
→ 38 scénarios dérivés d'une seule user story, chacun tracé à son critère
  d'acceptation, dont 11 marqués « confiance basse » avec la question ouverte
  nommée plutôt que tranchée en douce
→ aucun producteur ne note son propre travail : le score vit dans un plugin
  séparé, en lecture seule

Ce qui n'est pas prouvé, et je préfère l'écrire moi-même avant qu'on me le
demande : aucun pilote humain n'a jamais mené QAIA de bout en bout. Personne
n'a encore répondu à « est-ce que ça fait gagner du temps à un vrai testeur
sur du vrai travail ». C'est la plus grosse inconnue du projet.

C'est là que j'ai besoin de vous.

Je cherche 5 QA qui acceptent de l'essayer sur une vraie user story et de me
dire précisément où ça les déçoit. Un ticket qui explique pourquoi ça n'a pas
marché vaut plus, aujourd'hui, qu'une étoile GitHub.

MIT. Zéro étoile à l'heure où j'écris. On commence quelque part.

#QA #TestAutomation #ISTQB #Playwright #ClaudeCode #OpenSource #ShiftLeft
```

**Premier commentaire, à poster dans la foulée :**

```
Le dépôt : https://github.com/QAIA-Project/QAIA
Ce que ça donne concrètement (entrée réelle / sortie réelle) :
https://qaia-project.github.io/QAIA/

Et la page que personne n'écrit jamais — quel outil installer, y compris les
trois cas sur quatre où je recommande celui des autres :
https://qaia-project.github.io/QAIA/compare.html
```

---

## Version B — plus courte, angle « le détail qui change tout »

```
La plupart des générateurs de tests par IA ont le même défaut, et il est
invisible : quand la spécification est ambiguë, ils tranchent en silence.

Vous récupérez une suite qui a l'air complète. En réalité elle encode une
supposition — et elle l'encode exactement là où ça compte, à la frontière.
« Au-dessus de 500 € » : est-ce que 500 € pile passe ou pas ? Le générateur
a choisi. Il ne vous l'a pas dit.

Sur une user story de note de frais, mon outil a produit 38 scénarios.
Onze portent la mention « confiance basse » avec la question ouverte nommée
et le risque des deux réponses écrit noir sur blanc. Il ne les a pas
tranchées. Il les a remontées.

C'est plus lent. Et c'est la seule version qu'un auditeur accepte.

QAIA — skills Markdown pour Claude Code, MIT, pré-alpha assumée :
aucun pilote humain à ce jour, et le dépôt le dit en première ligne.

Lien en commentaire. Je cherche des gens pour l'essayer et me dire où ça casse.

#QA #TestAutomation #ISTQB #ClaudeCode #OpenSource
```

---

## Ce qu'il ne faut pas faire

- **Ne pas gonfler.** Le seul actif de ce projet est qu'il publie ses propres mauvaises notes.
  Un chiffre embelli se vérifie en trois clics — le dépôt est public — et détruit exactement ce
  qui rend le post intéressant.
- **Ne pas dire « révolutionner », « game changer », « boostez votre QA ».** L'audience QA
  francophone sur LinkedIn est saturée de ce registre et le sanctionne.
- **Ne pas répondre aux commentaires critiques par de la défense.** Un « vous avez raison, c'est
  noté, j'ouvre un ticket » — puis ouvrir le ticket pour de vrai et le lier — vaut dix
  arguments. C'est aussi la démonstration vivante de ce que le post raconte.
- **Ne pas poster deux fois la même semaine.** Un post, puis on laisse vivre.
