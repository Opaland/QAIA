# Audit — `visual-check` vs moteur de diff perceptuel (issue #40, P3)

Contexte : `docs/COMPETITIVE-ANALYSIS.md` note que `visual-check` existe (snapshots
Playwright + tolérance + déterminisme) mais que rien ne confirme s'il tient la
comparaison face à un moteur de diff perceptuel type Applitools (« Visual AI
perceptuelle » — détecter un changement visuel significatif indépendamment du
bruit de rendu, sans intervention humaine pour distinguer les deux).

Cet audit teste réellement la méthode documentée dans
`plugins/qaia-playwright/skills/visual-check/SKILL.md` (région stable, masquage
du contenu dynamique, `maxDiffPixelRatio`, `workers: 1`) sur 3 cas difficiles,
avec Playwright 1.62 / Chromium, sur un fixture autonome.

## Fixture

`eval/baselines/visual-check-audit-fixture/fixture.html` — page HTML/JS
autonome (pas de serveur, navigation `file://`), 3 régions :

- **Case A** — texte statique ("Enregistrer les modifications"). À chaque
  chargement, un script applique un `translateX` aléatoire de ±0.4px sur le
  texte : ceci simule un bruit de rendu (anti-aliasing / positionnement
  sous-pixel) sans aucun changement de contenu ni de sens — exactement le type
  de faux positif qu'un diff perceptuel doit ignorer.
- **Case B** — horloge JS (`setInterval`, mise à jour du texte chaque
  seconde) : contenu dynamique par nature, qui change à chaque capture
  indépendamment de tout bug.
- **Case C** — bouton + carte dont l'apparence dépend de `?variant=broken` :
  couleur du bouton (bleu → rouge) et layout cassé (la carte de résumé
  chevauche le bouton). C'est le vrai changement visuel significatif qui doit
  être détecté.

Harnais : `eval/baselines/visual-check-audit-fixture/tests/visual-audit.spec.js`,
`playwright.config.js` (`workers: 1`, Desktop Chrome), suit la méthode du
skill : screenshot scopé à la région (`page.locator(...).toHaveScreenshot`),
`maxDiffPixelRatio: 0.02` (valeur reprise de `examples/medibook`), masquage
Playwright (`mask: [...]`) pour la case B « bien testée ».

Protocole (calqué sur l'usage réel décrit par le skill) :
- **Run 1** (`--update-snapshots`) : crée les baselines — Case C avec
  `variant=baseline` (état correct). C'est une création de baseline, pas un
  "pass" au sens qualité (le skill le dit explicitement : "a first run is
  never a pass, it's baseline creation").
- **Run 2** (`AUDIT_VARIANT=broken`) : rejoue les captures — Case A et B sans
  changement de variant (leur contenu ne dépend jamais de la variante : seul
  le bruit/l'horloge diffère naturellement), Case C avec `variant=broken`
  (régression introduite). C'est la comparaison réelle, celle qui doit juger
  correctement.

## Résultats observés

| Cas | Attendu du skill | Résultat Run 2 | Verdict |
|---|---|---|---|
| A — bruit de rendu (AA) | ne pas signaler | **PASS** — 88 px différents sur ~78k px de la région (< 2% de tolérance) | OK |
| B1 — horloge **non masquée** | risque de faux positif/flake documenté par le skill | **PASS** (par chance) — 196 px différents (ratio arrondi 0.01) sur le run réel ; en rejouant 8 captures supplémentaires à ~0.7s d'intervalle, le diff est resté entre 13 et 210 px (ratio 0.0002–0.0027), toujours sous 2% | **Faux négatif silencieux** (voir analyse) |
| B2 — horloge **masquée** (`mask:` du skill) | ne pas signaler | **PASS** — 0 px différent, y compris en re-testant à tolérance 0 | OK, robuste |
| C — changement réel (couleur + layout) | détecter | **FAIL** — 7968 px différents, ratio **9%** (bien au-dessus des 2% de tolérance) | Détecté correctement |

Preuves : `eval/baselines/visual-check-audit-fixture/evidence/` (baselines
Case A/B/C, capture "broken" de Case C, et `case-c-diff.png` — le diff
Playwright montre nettement le bouton rouge et la carte décalée en surbrillance
jaune).

### Détail — pourquoi B1 est le résultat le plus intéressant

Le skill dit : *« Determinism first: seed data and freeze/mask dynamic content
before snapshotting — a flaky visual test is worse than none »* et recommande
`mask`/freeze, sans jamais suggérer de compter sur la tolérance seule pour
absorber du contenu dynamique non masqué. L'audit confirme que c'est le bon
conseil, mais pas pour la raison qu'on attendrait :

- Avec masquage explicite (B2), le diff est **exactement 0**, quel que soit le
  contenu réel de l'horloge — comportement déterministe et fiable.
- Sans masquage (B1), le diff n'est **pas nul** (l'horloge a bien changé de
  texte entre les deux captures) mais reste, dans tous les échantillons
  mesurés (9 captures au total, sur ~7 secondes réelles), **en dessous du
  seuil de tolérance de 2%** — donc le test passe silencieusement.

Autrement dit : sur ce fixture, l'absence de masquage ne s'est jamais traduite
par un flake visible (le scénario que le skill anticipe explicitement), mais
par un **faux négatif silencieux** — le mécanisme de tolérance masque le fait
que la région n'est pas réellement stable. C'est un risque différent de celui
documenté mais tout aussi réel : si un vrai bug visuel de faible amplitude
touchait la même région qu'un élément dynamique non masqué, une partie du
budget de tolérance serait déjà « consommée » par le bruit dynamique sans que
personne ne le sache, réduisant la marge de détection sans avertissement. Le
skill recommande déjà le bon remède (masquer/geler), mais ne documente pas
*pourquoi* c'est nécessaire au-delà du risque de flake — il vaudrait la peine
de nommer aussi ce second risque (tolérance qui absorbe silencieusement du
contenu dynamique non masqué, réduisant la marge réelle de détection).

## Verdict

**`visual-check` tient la comparaison sur les 3 cas testés — suffisant tel
quel pour son usage documenté, avec une lacune de documentation identifiée
plutôt qu'un défaut fonctionnel.**

- Le bruit de rendu (case A) ne déclenche pas de faux positif : la tolérance
  documentée (2%, valeur reprise telle quelle de `examples/medibook`) absorbe
  correctement l'anti-aliasing/positionnement sous-pixel sans intervention
  humaine — comportement attendu d'un moteur de diff perceptuel de base.
- Le contenu dynamique correctement masqué (case B2, méthode documentée par le
  skill) ne déclenche jamais de faux positif — comportement déterministe et
  robuste, conforme à la promesse du skill.
- Le vrai changement visuel (case C, couleur + layout cassé) est détecté sans
  ambiguïté (ratio 9%, très au-dessus du seuil) — le skill ne rate pas la
  vraie régression, contrairement à la crainte initiale de l'issue.

Point à renforcer (documentation, pas de code) : le guardrail actuel du skill
justifie le masquage seulement par le risque de flake ("a flaky visual test is
worse than none"). L'audit montre un second risque, plus insidieux, qui
mérite d'être nommé explicitement dans `SKILL.md` :

> Sans masquage, une zone dynamique non gelée peut aussi bien faire échouer le
> test par intermittence (flake) que le laisser passer silencieusement en
> consommant une partie de la tolérance — dans les deux cas la zone n'est pas
> réellement validée. Le masquage/gel n'est pas seulement anti-flake, il est
> anti-faux-négatif-silencieux.

Cela ne change rien à la méthode déjà recommandée (mask/freeze avant tout) ;
c'est une clarification du "pourquoi" qui aiderait un lecteur humain à ne pas
sous-estimer le risque de laisser du contenu dynamique non masqué "parce que
ça a l'air de passer".

Le skill n'a par ailleurs jamais prétendu faire de la détection perceptuelle
sans région scopée — contrairement à Applitools qui peut classifier des
diffs sur une page entière sans découpage manuel. `visual-check` reste un
diff pixel/tolérance appliqué à des régions choisies par l'auteur du test,
pas un moteur "AI visuel" au sens propre ; mais pour l'usage documenté (tests
de régression visuelle scopés, avec masquage explicite du contenu dynamique),
il produit les bons verdicts sur les 3 cas testés.

## Reproduire

```bash
cd eval/baselines/visual-check-audit-fixture
npm install
npx playwright install chromium   # si browser absent
npx playwright test --update-snapshots   # Run 1 — crée les baselines
AUDIT_VARIANT=broken npx playwright test # Run 2 — comparaison réelle (case C doit échouer, A/B doivent passer)
```
