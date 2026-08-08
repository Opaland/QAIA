# Compatibilité navigateurs et appareils : choisir, pas couvrir

Playwright exécute nativement sur Chromium, Firefox et WebKit, et émule les appareils. La mécanique
est donc déjà là — `examples/medibook` porte un projet `e2e-mobile` sur Pixel 7 depuis des sprints.

**Ce qui manquait n'est pas la mécanique, c'est le raisonnement.** Cette note le fournit ; il n'y a
pas de skill séparée, parce que multiplier une suite par un tableau de navigateurs n'est pas une
compétence, c'est une ligne de configuration. La compétence est de choisir quoi rejouer.

## Le piège, nommé d'abord

Une matrice exhaustive — chaque scénario × chaque moteur × chaque appareil — **coûte cher et
attrape peu**. Elle triple le temps de CI, multiplie les instabilités, et la grande majorité des
exécutions supplémentaires re-vérifient une logique métier qui ne dépend d'aucun moteur.

Un scénario qui appelle une API et vérifie un statut donne exactement le même résultat sur trois
moteurs. Le rejouer trois fois n'achète rien.

## Ce qui dépend réellement du moteur

Rejouer sur plusieurs moteurs ce qui touche **le rendu, la saisie ou une API navigateur** :

| Sujet | Pourquoi il diverge |
|---|---|
| Mise en page, `flex`/`grid`, débordements | moteurs de rendu distincts |
| Champs `date`, `number`, `file` | contrôles natifs, très différents entre WebKit et Chromium |
| Focus, ordre de tabulation, navigation clavier | comportements natifs divergents |
| `localStorage`, cookies tiers, `SameSite` | politiques de confidentialité différentes selon le moteur |
| Formats média, polices | support inégal |
| Gestes, `viewport`, barres système | c'est le sujet même du mobile |

## Ce qui n'en dépend pas

- **Tout ce qui passe par `request`** — un test d'API n'a pas de moteur. Dans `examples/expense-demo`,
  cela représente 43 tests sur 56 : les rejouer sur trois navigateurs ajouterait 86 exécutions qui
  ne peuvent rien découvrir.
- **La logique métier vérifiée par du texte** — un montant, un statut, un message.
- **Les instantanés visuels** — ils sont déjà par plateforme (`*-win32.png`) ; les croiser avec
  plusieurs moteurs multiplie les références à régénérer, pas les défauts trouvés.

## La règle

**Un projet `e2e` par moteur, jamais plus, et jamais sur les autres types.**

```js
projects: [
  { name: 'api',          testMatch: /api\..*\.spec\.js/ },                       // sans moteur
  { name: 'e2e-chromium', testMatch: /e2e\..*\.spec\.js/, use: devices['Desktop Chrome'] },
  { name: 'e2e-webkit',   testMatch: /e2e\..*\.spec\.js/, use: devices['Desktop Safari'] },
  { name: 'e2e-mobile',   testMatch: /e2e\..*\.spec\.js/, use: devices['Pixel 7'] },
  { name: 'a11y',         testMatch: /a11y\..*\.spec\.js/, use: devices['Desktop Chrome'] },
  { name: 'visual',       testMatch: /visual\..*\.spec\.js/, use: devices['Desktop Chrome'] },
]
```

WebKit avant Firefox si un seul moteur supplémentaire est possible : c'est celui qui diverge le
plus, et c'est le moteur de tous les navigateurs sur iOS.

## Une différence attendue n'est pas un défaut

Certaines divergences sont **conformes** : un `<input type="date">` ne s'affiche pas pareil sur
WebKit et Chromium, et aucun des deux n'a tort. Un test qui échoue là-dessus est un test mal écrit,
pas un défaut de compatibilité.

Conséquence directe sur la façon d'écrire : viser le **comportement observable** — la valeur reçue
par l'application — plutôt que la mécanique d'interaction avec le contrôle natif. Un test qui
dépend de la façon dont un moteur ouvre un sélecteur de date ne teste pas l'application.

## Ce qu'il faut refuser

- **Élargir la matrice pour rassurer.** Chaque projet ajouté doit nommer ce qu'il peut découvrir que
  les autres ne découvrent pas.
- **Croiser visuel et moteurs sans un besoin explicite.** Les références sont déjà par plateforme ;
  le croisement multiplie la maintenance avant les trouvailles.
- **Rejouer les tests d'API sur plusieurs moteurs.** Ils n'en ont pas.
- **Traiter une divergence de rendu natif comme un défaut** sans avoir vérifié que le comportement
  observable, lui, diffère.
