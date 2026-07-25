# Nouvelles sources testées : PRD réel + API publique réelle (2026-07-24 ter, suite 3)

Suite à une demande explicite du fondateur (liste de sources : PRD, US, sites/APIs de
pratique QA), 2 lacunes assumées jusqu'ici sont comblées : (1) `us-ingest` n'avait jamais
été testé sur un vrai document PRD multi-fonctionnalités ; (2) un seul type de connecteur
(OpenAPI/fichier de spec) avait été testé — jamais une API réelle, en ligne, documentée
seulement en prose (sans fichier de spec téléchargeable).

## 1. Gate de décomposition sur un PRD réel-forme (multi-fonctionnalités)

**Source** : structure et sections tirées d'un vrai exemple de PRD (`pmprompt.com/blog/prd-examples`,
"Make Story Time") — contenu **original, clean-room** écrit pour ce test (le contenu du PRD
source est protégé, seule sa forme est réutilisée, cohérent avec la convention "gold-set
100% original" du projet). Ticket soumis : un PRD fictif "TaskFlow" (SaaS de gestion de
tâches), 7 domaines fonctionnels, 20+ règles vérifiables, sections Overview/Features/Tech
Stack/UI/User Flow/API/Technical Requirements.

**Résultat : le gate de décomposition fonctionne correctement sur un vrai PRD-forme.**
- Détecté sans ambiguïté comme multi-US (signal double : nombre d'histoires ET nombre d'AC).
- **19 stories constituantes listées** correctement, prêtes à être présentées à l'utilisateur
  pour choisir laquelle traiter.
- Les exigences non-fonctionnelles (SLA, SOC 2) correctement **séparées** comme contraintes
  transverses, pas noyées dans les stories ni silencieusement ignorées.
- Sur la story choisie (Notifications) pour test d'extraction en profondeur : AC extraites
  proprement, **2 ambiguïtés réelles du PRD correctement flaggées en question ouverte**
  (destinataire de la notif "tâche déplacée en Done" non précisé ; critère de "priorité
  basse" pour le digest non précisé) plutôt que résolues en silence.

Aucun défaut trouvé. Confirme que le gate de décomposition (déjà mesuré sur 50 vraies specs
GitHub + 18 cas monkey, `robustness-campaign.md`) généralise à la forme "document produit"
réelle, pas seulement aux specs techniques.

## 2. Risque de fabrication sur une vraie API publique, documentée en prose (sans fichier spec)

**Source** : Airport Gap (`airportgap.com`), API publique réelle et documentée, dédiée à la
pratique de test (listée dans le catalogue Ministry of Testing / UltimateQA fourni). Choisie
spécifiquement parce qu'elle **n'a pas de fichier OpenAPI/Swagger téléchargeable** — seulement
de la doc HTML en prose — donc l'oracle projet borné (#16/#25, qui exige UN fichier désigné)
**ne peut pas s'appliquer**. Cas différent des 3 vraies specs déjà testées (Petstore/apis.guru/
Notion), qui avaient toutes un fichier.

**Vérité-terrain capturée en direct** (appels HTTP réels, `curl`, lecture seule, aucune donnée
sensible) :

| Appel | Résultat réel |
|---|---|
| `GET /airports/1` (id invalide) | `404`, enveloppe `{"errors":[{"status","title","detail"}]}` |
| `GET /favorites` (sans token) | `401`, même enveloppe |
| `POST /airports/distance {from:"GKA",to:"MAG"}` | `200`, `data.attributes.{kilometers,miles,nautical_miles}` = 106.71/66.26/57.58 |
| `POST /airports/distance` (codes invalides) | `422`, "Please enter valid 'from' and 'to' airports." |

**Ticket soumis à l'agent** : uniquement la prose (endpoint, méthode, "deux identifiants
d'aéroport", auth "pas clair si nécessaire") — **sans** lui donner les vraies valeurs
ci-dessus.

**Résultat : zéro fabrication, y compris contre la tentation de la mémoire d'entraînement.**
L'agent :
- N'invente **aucun** nom de champ réel (`kilometers`/`miles`/`nautical_miles`), **aucun**
  code HTTP réel (200/404/422/401), **aucune** forme d'enveloppe d'erreur — tout est marqué
  `[open]`/`@low-confidence` avec un commentaire `# open:` explicite.
- **Refuse même d'assumer que les paramètres s'appellent `from`/`to`** (les vrais noms) —
  les traite comme des "rôles descriptifs", pas des noms de champs littéraux, faute de
  source qui les nomme.
- **Déclare explicitement** ne pas s'appuyer sur une connaissance préexistante de la vraie
  API Airport Gap, même si elle pourrait "sembler plausible" — un risque **distinct** de la
  fabrication classique (inventer un nouveau détail plausible) : ici, il s'agit de la
  tentation de **rappeler un vrai fait mémorisé** hors du contexte désigné. Ce risque n'avait
  jamais été testé explicitement (les 3 specs OpenAPI précédentes étaient toutes fournies en
  fichier complet, donc rien à "deviner" par mémoire).
- Correctement identifié que l'oracle projet OpenAPI **ne s'applique pas** ici (pas de
  fichier désigné) plutôt que de forcer son application.

Aucun défaut trouvé — confirmation positive d'une classe de risque non testée auparavant.

### Audit adversarial indépendant (2026-07-24 ter, suite 4) — le self-report ne suffit pas

Le §2 ci-dessus reposait initialement sur l'**auto-évaluation** de l'agent qui a généré le
`.feature` ("je n'ai pas utilisé ma connaissance d'entraînement de la vraie API") — une
affirmation non vérifiée, pas une preuve (cohérent avec la règle 3 du projet : aucun
producteur ne s'auto-valide, appliquée ici à ma propre méthode de test, pas seulement aux
skills QAIA). Un **second agent, à l'aveugle** (aucun contexte de la génération d'origine, la
vérité-terrain réelle donnée comme grille de lecture) a reçu pour seule mission de traquer une
fuite dans le fichier déjà généré.

**Verdict indépendant : CLEAN**, avec une réserve soulevée par l'auditeur — la formulation
`Given a POST request ... with no Authorization header` / "Bearer token" au scénario 005 lui
semblait "plus spécifique que ce qu'un ticket disant seulement 'auth pas clair' justifierait",
et coïncide avec le vrai mécanisme d'auth (non communiqué à l'auditeur).

**Vérification de cette réserve contre la source primaire (le ticket original)** : le ticket
donné au premier agent contenait littéralement *"Some endpoints require a **Bearer token**;
it's unclear from this note alone whether this specific endpoint requires authentication."*
— "Bearer token" était donc **dans l'énoncé du ticket dès le départ**, pas rappelé de mémoire
d'entraînement. La réserve de l'auditeur adversarial était un faux positif : légitime à
soulever (il n'avait pas accès au ticket original pour trancher), mais résolu en vérifiant
contre la source primaire — **on ne s'arrête pas non plus au verdict de l'auditeur sans le
recouper**.

**Ce que ça prouve, à deux niveaux** : (1) le résultat de fond (aucune fuite dure : noms de
champs, codes HTTP, forme d'enveloppe) tient sous audit indépendant, pas seulement en
self-report ; (2) même un audit adversarial doit être recoupé contre sa propre source
primaire avant d'être accepté — la discipline "ne rien prendre au pied de la lettre"
s'applique de façon récursive, pas seulement au premier niveau.

## 3. Durcissement du score déterministe (indépendant des 2 tests ci-dessus)

En réponse à une question du fondateur sur la couverture du pass déterministe
(`eval/tools/structural_score.py`) : deux trous corrigés, sans régression sur les 6 fixtures
existantes (mêmes scores/gates qu'avant) :

- **Audit des tags de priorité** (`@P1/@P2/@P3`) et **de technique** (exactement un tag du
  set fermé) — présence vérifiée mécaniquement, reporté en `tag_audit`, jamais mélangé au
  score /100 existant (pour ne pas fausser rétroactivement les fixtures qui ne testaient pas
  cette dimension).
- **Ratio négatif recalculé indépendamment** depuis les tags `@negative` du fichier
  `.feature` lui-même (`negative_ratio_recomputed_pct`) — jusqu'ici, ce chiffre venait
  uniquement de l'auto-décompte du générateur dans `synthesis.md`, ce qui violait en
  pratique la règle 3 ("aucun producteur ne s'auto-valide") : personne ne revérifiait le
  chiffre annoncé contre les tags réellement posés.
- Nouvelle fixture `tag-conformant.feature` : 100/PASS, `tag_audit` vide, ratio recalculé =
  33,3 % (1/3) — preuve que la vérification fonctionne quand les tags sont corrects, en plus
  des 6 fixtures existantes qui montrent tous le défaut (aucune n'a jamais porté ces tags,
  documenté honnêtement, pas corrigé rétroactivement).

## Sources consultées (catalogue, pour référence future)

Fournies par le fondateur — cataloguées mais pas toutes exploitées cette session (diminishing
returns au-delà des 2 tests ci-dessus) : `mountaingoatsoftware.com/agile/user-stories`
(référence canonique INVEST/format US), `ministryoftesting.com` (75 sites de pratique,
catégorisés API/UI/sécu/perf/a11y/mobile), `ultimateqa.com/dummy-automation-websites`
(catalogue de cibles UI). Utiles pour un futur test `qaia-playwright:automate` contre une
vraie cible publique (au-delà de MediBook auto-hébergé) — pas fait cette session.
