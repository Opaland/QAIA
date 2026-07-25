# Corpus élargi — profondeur statistique (2026-07-24 ter, suite 13)

*Suite à D55-D57 (balayage en largeur, N=1/skill) : le fondateur demande de creuser en
profondeur sur du matériel neuf pour voir si les patterns tiennent à plus grande échelle.
Plan complet : `eval/goldset-hardened/corpus-24-plan.md` (24 cas). Exécution par lots pour
respecter les paliers gratuits (Gemini a re-tapé un 429 après R1 — décision fondateur :
continuer sans lui, le rajouter plus tard si le quota se libère).*

## Lot 1 — 4 cas réels (GitLab CE v8.16.9, jamais utilisés cette session)

| Cas | Sujet | Claude | Gemini | Groq | Hugging Face | Mistral |
|---|---|---|---|---|---|---|
| R1 | Dédup labels sur un jalon | ✅ démonstration concrète | ✅ (1/1 dispo) | ⚠️ dédup tautologique, pas démontrée | ✅ démonstration concrète, la plus riche | ⚠️ dédup tautologique, pas démontrée |
| R2 | Subscribe/unsubscribe à un label | ✅ | rate-limité | ✅ | ❌ **invente des codes HTTP précis (201/404/409) non implicites** | ✅ |
| R3 | Création projet + précondition SSH (piège) | ✅ | rate-limité | ✅ | ✅ | ✅ |
| R4 | Matrice visibilité explore (public/interne/privé/archivé) | ✅ | rate-limité | ✅ | ✅ **la plus rigoureuse ici** | ❌ **invente une exception "propriétaire" non fondée pour les projets privés** |

### Défauts trouvés (2 nouveaux, s'ajoutent à D55)

**Hugging Face — fabrication de littéraux techniques (R2).** Le ticket ("As a project member,
I want to subscribe to a label...") ne mentionne aucune API REST. HF assert pourtant des codes
de statut précis et non signalés comme hypothèse : `201` (souscription), `404` (label
inexistant), `409` (déjà souscrit). Aucun autre modèle n'invente ces codes. C'est le
**4e défaut distinct** trouvé chez HF cette session (fuite PII, règle énoncée non appliquée,
faux positif C2, et maintenant fabrication de littéraux) — un profil de confiance mal placée
qui se confirme sur un 4e skill/cas différent.

**Mistral — invention d'une exception non fondée (R4).** Le ticket dit seulement "public,
interne (visible aux utilisateurs connectés), ou privé" — aucune notion de "propriétaire"
n'est introduite. Mistral construit pourtant une ligne de matrice "private | signed-in |
active → Visible (owned)" et un scénario qui l'assume, avant de la re-flaguer en gap
seulement après coup. Les 4 autres modèles gardent "privé = caché pour tous" sur cette page
de découverte, cohérent avec le ticket. Nouveau défaut pour Mistral (différent de son échec
de traçabilité sur `report`, D56) : ici c'est une fabrication, pas un oubli mécanique.

### Confirmation d'un signal déjà vu

**Groq et Mistral produisent une assertion de dédoublonnage tautologique** (R1) : "the labels
tab lists all unique labels used" sans jeu de données concret démontrant que 2 issues
partageant un label ne le font apparaître qu'une fois — contrairement à Claude/Gemini/HF qui
construisent un exemple chiffré. Un défaut plus léger que C1/C2 (l'assertion n'est pas creuse
au sens strict), mais une réapparition du thème "structure correcte, preuve non démontrée".

**R3 (piège SSH) : sans-faute total**, y compris sur les 4 modèles gratuits — aucun n'a
conflaté la présence d'une clé SSH avec une précondition bloquant la création du projet.
Bonne nouvelle : ce piège spécifique n'est pas aussi difficile qu'anticipé.

## Lot 2 — 4 cas clean-room (C1-C4)

*4 agents indépendants, un par cas, chacun rédigeant son propre ticket dur clean-room, sa
propre génération Claude (en appliquant réellement `us-ingest`/`istqb-design`/
`testbook-generate`) et son propre appel aux 4 fournisseurs via `multi_model_generate.py`.
Gemini disponible sur les 4 cas cette fois (pas de 429) ; Cerebras a échoué en 402 partout,
ignoré comme prévu.*

| Cas | Sujet | Défaut ciblé | Claude | Gemini | Groq | Hugging Face | Mistral |
|---|---|---|---|---|---|---|---|
| C1 | Fintech — virement, contradiction triple-AC (plafond vs OTP vs limite journalière) | Contradiction multi-règles | ✅ | ✅ | ❌ résout en silence, pas d'OTP appliqué sur $100k | ❌ résout en silence, cumul non fondé | ✅ |
| C2 | Logistique — PRD, PII (nom/adresse/téléphone) dans un mockup | PII dans les exemples | ✅ | ✅ (arm la plus complète) | ❌ **déclare avoir masqué puis imprime la donnée brute** | ⚠️ inconcluant (s'arrête avant de générer le cahier) | ⚠️ cahier propre mais **ledger** dans le résumé |
| C3 | Santé — Spec/RFC, dossier patient, config-driven (visibilité + bornes cliniques) | Ambiguïté config-driven non signalée | ✅ | ✅ **la plus rigoureuse** | ❌ invente une borne de température | ❌ invente une matrice rôle-visibilité + des seuils | ❌ invente des seuils cliniques (glycémie/TA) |
| C4 | EdTech — Jira-ticket, notes d'examen, IDs de scénario | Traçabilité/provenance (IDs `@QAIA-xxx`) | ✅ | ✅ (IDs ok, ratio jamais reporté) | ✅ (IDs ok, ratio non calculé, redondance) | ✅ (IDs ok, **ratio auto-rapporté faux**) | ✅ (IDs ok, mais 2 fabrications + contradiction non flaguée) |

### Défauts trouvés (lot 2)

**Hugging Face — 5e défaut distinct : résolution silencieuse d'une contradiction (C1).**
Sur le virement à trois règles en collision, HF affirme comme un fait plat, non couvert par
le ticket, que le plafond journalier standard-tier s'applique "own-account *and* third-party
transfers" combinés, puis applique l'OTP sur un virement compte-à-compte de $10 001 sans
aucun flag `@low-confidence` ni section contradiction/gap. Aucune des 4 autres sources
(Claude, Gemini, Mistral) ne fait ce choix silencieusement — toutes le posent en question
ouverte. S'ajoute à la fuite PII (D55), la règle énoncée non appliquée (D55), le faux positif
C1/C2 (D55) et la fabrication de codes HTTP (D58/lot 1) — **5 défauts distincts sur 5
cas/skills différents**, chaque fois un écart entre ce que HF *dit* et ce qu'il *fait*.

**Hugging Face — 6e défaut distinct : fabrication concrète en terrain config-driven (C3).**
Sur la spec santé, HF invente une matrice rôle→visibilité complète (`Doctor: visible,
Nurse: visible, AideSoignant: hidden`) et des seuils cliniques précis (35.0°C / 38.5°C),
aucun des deux dérivable de la spec, aucun tag `@low-confidence` sur les scénarios
concernés — alors que Gemini reste générique sur le même cas. Confirme et étend le pattern
D38 (fabrication de littéraux config-driven) à un nouveau domaine (santé) et un nouveau
fournisseur touché deux fois sur ce seul lot.

**Groq — confirme un défaut de raisonnement profond sur un 2e cas (C1) et un 3e (C3).**
Sur C1, Groq ne signale aucune contradiction et fait passer un virement de $100 000 comme
"instant et réussi" sans OTP ni vérification de plafond. Sur C3, Groq invente une borne
numérique de température (0-100) absente de la spec, en `Examples:` Gherkin concret, sans
flag. Confirme le profil "raisonnement multi-règles" de D55 (piège Groq initial) sur deux cas
neufs et deux domaines différents (fintech, santé).

**Mistral — confirme le profil "invention non fondée" sur un 2e cas (C3) et un 3e (C4).**
Après R4 (lot 1, exception "propriétaire" inventée), Mistral invente ici des seuils cliniques
concrets avec verdicts `true`/`false` (C3, glycémie/tension) et deux mécanismes absents du
ticket sur C4 (fenêtre d'examen "pas encore ouverte", erreur réseau à l'auto-save) — aucun
des trois flagué `@low-confidence`. Sur C1 et C2 en revanche, Mistral se comporte
correctement (pas de fabrication) — pas un profil systématique sur toutes les tâches, mais un
mode d'échec récurrent (3 occurrences/4 cas) qui mérite maintenant d'être traité comme un
signal établi, pas un artefact isolé.

**Nouveau — fuite PII "narrative" hors artefact (C2, Groq et Mistral).** Le testbook Gherkin
généré par Mistral est propre (toutes les valeurs en `[REDACTED:...]`), mais son résumé de
rédaction imprime explicitement la table de correspondance donnée brute → placeholder
("14 rue des Lilas... → [REDACTED:address]") — un **ledger textuel**, exactement ce que
D37 interdit, même si l'artefact final est net. Groq va plus loin : il déclare avoir masqué
puis réimprime directement la donnée brute entre parenthèses, sans même produire de
placeholder. Nuance nouvelle par rapport à D37/D55 : le canal de fuite n'est pas toujours le
testbook lui-même, il peut être la narration du modèle autour de l'artefact — un futur gate
outillage mainteneur devrait inspecter la sortie complète du modèle, pas seulement le
`.feature` extrait.

**Confirmation transversale — le ratio négatif D20 auto-rapporté est presque toujours faux ou
absent, même quand l'artefact sous-jacent est correct (C1, C3, C4).** Sur C1, Groq énonce
"20%... 4 out of 10" (les deux chiffres se contredisent). Sur C3, Groq et Hugging Face
rapportent tous deux un dénominateur ou un compte faux. Sur C4, Gemini et Groq ne calculent
simplement pas le ratio, Hugging Face le calcule mais faux (annonce 5/12, le grep réel donne
4/12), et Mistral ne le rapporte pas du tout tout en sous-taguant ses propres scénarios de
refus. **Ce n'est pas un nouveau problème produit** — c'est une confirmation directe de la
raison pour laquelle D50 a déjà fait recalculer ce ratio de façon déterministe et indépendante
dans `structural_score.py` plutôt que de faire confiance à l'auto-décompte du générateur : le
signal se répète maintenant sur 3 cas neufs et 4 fournisseurs différents, y compris quand
Claude (jamais en défaut sur ce point dans ce lot) est la seule source fiable en amont du
scoreur déterministe.

**Sans-faute confirmé : Claude et Gemini, 4/4 cas chacun, aucun défaut trouvé.** Gemini reste
la source la plus rigoureuse sur C3 (config-driven) et la plus complète sur C2 (25
scénarios, aucune fuite). Claude n'a montré aucun défaut sur les 4 cas du lot 2 (8/8 cumulé
avec le lot 1).

## Lot 3 — 4 cas clean-room (C5-C8)

| Cas | Sujet | Défaut ciblé | Claude | Gemini | Groq | Hugging Face | Mistral |
|---|---|---|---|---|---|---|---|
| C5 | Gaming — classement saisonnier, égalités à 3 niveaux | Structurel C2 (`Then` non-vérifiable) | ✅ 96/100 | ✅ | ❌ `Then` vagues, s'auto-critique sans corriger | ✅ | ❌ **exactement sur la zone d'égalité ciblée**, non capté par le détecteur auto |
| C6 | IoT/domotique — collision volets ouverture/fermeture (SUPPORT-881) | Contradiction multi-règles | ✅ | ✅ (trouve 2 collisions, mieux que Claude) | ❌ résout en silence, auto-rapport contredit sa propre extraction | ✅ | ❌ flague la collision secondaire mais résout celle ciblée en silence |
| C7 | HR-tech — congés, PII (nom/matricule/motif médical) | PII dans les exemples | ✅ | ✅ mais **1er défaut annexe** (codes HTTP fabriqués) | ⚠️ n'a pas réutilisé l'exemple PII — non concluant | ✅ | ✅ (contraste avec sa fuite ledger du lot 2, pas systématique) |
| C8 | Voyage — tarification dynamique config-driven | Ambiguïté config-driven | ✅ | ✅ | ✅ cible atteinte, mais gap non propagé au testbook + ratio faux | ✅ **1er cas propre de HF sur 7** | ✅ cible atteinte, mais ratio gonflé + contradiction AC5 non flaguée |

### Défauts trouvés (lot 3)

**Mistral échoue exactement dans la zone d'égalité totale ciblée (C5) — et le détecteur
déterministe le rate.** Sur le départage à 3 niveaux (rating/pertes/date), Mistral écrit
`Then the tie is broken by a deterministic rule (e.g., lexicographical order...)` sans jamais
asserter un ordre observable réel — `structural_score.py` (`VAGUE_RE`) ne capte pas cette
formulation et rend un gate PASS (88) malgré un défaut identifiable à l'œil. **Gap outillage
réel** (pas encore corrigé cette session, à traiter comme suite du #24/D46 si un futur amendement
touche le scoreur) : la regex de détection C2 est trop étroite pour les formulations qui se
réfèrent à "une règle" sans la citer.

**Mistral confirme son profil d'invention non fondée pour la 4e et 5e fois cette session (C5,
C6).** S'ajoute à R4 (lot 1), C3 et C4 (lot 2) : sur C6, il flague correctement une collision
secondaire (A vs B) mais résout la collision *ciblée* (B vs C, celle du ticket support cité en
preuve) en silence, et invente une règle absente (AC12, désactivation manuelle ignorée). Le
mode d'échec est maintenant établi sur 5/12 cas cumulés, pas un artefact isolé.

**Groq confirme sa faiblesse de raisonnement multi-règles pour la 3e et 4e fois (C5, C6),
avec une nuance nouvelle : il se voit et ne se corrige pas.** Sur C5, Groq écrit lui-même en
fin de sortie que son `Then` "pourrait être plus spécifique" sans jamais réémettre le
Gherkin corrigé. Sur C6, son propre résumé final affirme "aucun scénario `@low-confidence`,
car tout est explicitement défini" — contredit frontalement sa propre section d'extraction
qui admettait l'ambiguïté quelques lignes plus haut. Confirme le profil D55/D58/D59 sur deux
cas neufs et deux domaines (gaming, IoT).

**Gemini montre son premier défaut sur ce corpus (C7) — la série sans-faute de 8/8 cas est
rompue.** Fabrique des codes HTTP précis (401, 403×2) sur des scénarios d'autorisation absents
d'une spec qui ne mentionne aucune API REST — même mode d'échec que celui trouvé chez Hugging
Face au lot 1 (D58), ici chez un fournisseur jusque-là irréprochable. Signal à surveiller, pas
encore un profil (1 seul cas sur 12).

**Hugging Face enchaîne 3 cas propres consécutifs (C6, C7, C8) après 6 défauts distincts sur
les 8 cas précédents.** Rupture nette de tendance à mi-corpus — trop tôt pour conclure à une
amélioration systématique (le protocole ne contrôle pas la variance intra-modèle d'un run à
l'autre), mais le signal mérite d'être noté honnêtement plutôt que lissé dans la moyenne
cumulée. Seul résidu mineur sur C5 : une incohérence numérique de départage non flaguée
(deux joueurs à égalité de rating sans donnée de départage justifiant l'ordre asserté).

**Confirmation transversale, encore : le ratio D20 auto-rapporté reste peu fiable** (Groq sur
C8 : "2 out of 11" alors qu'1 seul scénario porte `@negative` ; Mistral sur C8 gonfle 4/9 en
comptant des confirmations de prix comme des refus). Continue de valider D50.

## Lot 4 — 4 cas clean-room (C9-C12)

*Hugging Face indisponible sur 3/4 cas de ce lot (`HTTP 402 Payment Required`, confirmé sur
plusieurs tentatives distinctes — pas un artefact transitoire comme le 429 des lots
précédents, plutôt un épuisement de crédit gratuit). Rapporté honnêtement, jamais fabriqué.*

| Cas | Sujet | Défaut ciblé | Claude | Gemini | Groq | Hugging Face | Mistral |
|---|---|---|---|---|---|---|---|
| C9 | Immobilier — visite, gap d'annulation non décrit | CRUD-inverse implicite | ✅ | ✅ (mais mistague `@negative` sur exclusion de liste) | ✅ faible (gap nommé seulement en synthèse finale, pas tracé en amont) | ✅ (gap nommé en prose, pas de scénario) | ✅ le plus rigoureux (CRUD+inverses appliqué littéralement) |
| C10 | Média/streaming — recommandations, mockup détaillé | Structurel C1 (`Then` creux) | ✅ | ✅ (mais fabrique 2 comportements non spécifiés) | ✅ strict, mais **near-miss stylistique** non capté par `HOLLOW_RE` | indisponible (402) | ✅ (mais 6e occurrence surconfiance + contredit son propre Background) |
| C11 | Fintech — KYC, collision re-vérification vs exemption | Contradiction multi-règles | ✅ | ✅ (mais fabrique des codes d'erreur + une limite contredisant la spec) | ✅ imprécis (mauvais cadrage + erreur de calcul de palier) | indisponible (402) | ✅ (mais sur-flague une non-ambiguïté, dilue le signal) |
| C12 | Logistique — retours produits, Jira-ticket | Traçabilité/provenance (IDs) | ✅ | ✅ sans-faute | ✅ IDs ok, mais `Then` réduits à un commentaire sur 2 `[open]` | indisponible (402) | ✅ IDs ok, mais ratio massivement obsolète + 2 fabrications |

### Défauts trouvés (lot 4)

**Sans-faute total sur les deux défauts ciblés les plus "de détection" (C9, C10, C11) — la
vraie valeur de ce lot est dans les défauts annexes, désormais très denses.** Aucun
fournisseur disponible n'a échoué C9 (gap CRUD-inverse) ni C11 (contradiction, au sens
détection) — mais la qualité d'intégration varie fortement (Mistral/Gemini l'intègrent
proprement au pipeline, Groq le mentionne seulement en synthèse finale sans le tracer en
amont, une nuance qui échappe à un simple PASS/FAIL binaire).

**2e gap outillage trouvé dans le scoreur déterministe (C10, Groq).** `Then the row order is
exactly as drawn` — un renvoi paraphrasé au mockup, non capté par `HOLLOW_RE` (pas de
mot-clé "maquette/mockup" reconnu), rejouant exactement le type de trou trouvé en C5
(`VAGUE_RE` sur Mistral) : `structural_score.py` reste vulnérable aux formulations qui évoquent
une preuve externe ou une règle non précisée sans utiliser le vocabulaire attendu par les
regex. Deux gaps du même type en 2 lots consécutifs — signal suffisant pour justifier une
correction avant de considérer le détecteur C1/C2 fiable en routine (non fait cette session).

**Groq — `Then` réduit à un commentaire sur un `[open]` (C12), nouvelle nuance.** Sur deux
scénarios marqués `[open]`, Groq écrit `Then # open: Q1 (full or partial refund?)` — un
commentaire à la place d'une assertion réelle, violant la règle testbook-generate "ne jamais
sauter en silence, générer avec le comportement par défaut sûr". Différent des fabrications
déjà notées : ici Groq évite bien la fabrication, mais au prix de ne rien générer de testable.

**Confirmation transversale répétée (5e-6e fois) : le ratio D20 auto-rapporté reste peu
fiable, y compris sur des cas où l'artefact est par ailleurs correct** (Groq sur C11/C12,
Mistral sur C10/C11/C12 — sur C12 l'en-tête du fichier Mistral affirme "6/15 = 40 %" alors que
le corps contient 19 scénarios et 10 tags réels, dénominateur ET numérateur faux). Continue
de valider D50 de façon de plus en plus large.

**Mistral — le profil de fabrication/surconfiance non fondée continue de se confirmer**
(C10 : affirme à tort que tous les seuils sont explicites + contredit son propre `Background` ;
C12 : deux scénarios inventés hors ticket, deux tags `@negative` mal classés) — recurrent sur
la majorité des cas du corpus à ce stade, plus un mode d'échec occasionnel qu'un artefact.

**Hugging Face — indisponibilité opérationnelle, pas un défaut de qualité.** 3 échecs 402
consécutifs (C10, C11, C12) après une série de 4 cas propres (C6-C9) — signal de crédit
gratuit épuisé pour cette session, distinct des défauts de raisonnement déjà documentés ; à
distinguer clairement dans le bilan final (couverture partielle sur ce fournisseur, pas un
profil de qualité amélioré ou dégradé).

## Lot 5 — 4 cas clean-room (C13-C16)

*Hugging Face indisponible sur les 4 cas de ce lot (`402 Payment Required`, confirmé 7 fois
consécutives depuis C10 — crédit gratuit épuisé pour la session, pas un défaut de qualité).*

| Cas | Sujet | Défaut ciblé | Claude | Gemini | Groq | Hugging Face | Mistral |
|---|---|---|---|---|---|---|---|
| C13 | Santé — rendez-vous, PII (nom/DOB/motif médical) | PII dans les exemples | ✅ | ✅ sans-faute, ratio exact | ✅ sur la fuite, mais **saute le log de redaction exigé** | indisponible (402) | ✅ sur la fuite, mais **mal-classe la catégorie PII** (santé→"phone") |
| C14 | EdTech — devoirs, config-driven (fenêtre de grâce, plafond resoumission) | Ambiguïté config-driven | ✅ | ✅ sans-faute, ratio exact | ✅ cible atteinte, ratio faux | indisponible (402) | ❌ **invente une valeur chiffrée dans le Gherkin exécutable + fabrique un axe entier absent**, auto-contredit sa propre synthèse |
| C15 | Gaming — anti-triche, collision appel/escalade (TS-4417) | Contradiction multi-règles | ✅ | ✅ le plus complet, ratio exact | ❌ **rate le cas ciblé, cahier tronqué, auto-contradiction arithmétique** | indisponible (402) | ✅ détection correcte, mais **aucun scénario dédié généré** |
| C16 | IoT — notifications, gap de désabonnement | CRUD-inverse implicite | ✅ | ✅ (1 fabrication annexe non taguée) | ✅ (sous-tagging, couverture mince) | indisponible (402) | ✅ le plus rigoureux |

### Défauts trouvés (lot 5)

**Mistral échoue nettement sur C14 — 7e occurrence de son profil, la plus sérieuse à ce
stade.** Invente une fenêtre de grâce chiffrée ("5-day window") **directement dans un `Given`
Gherkin exécutable**, tag `[open]` ou pas, et fabrique un **axe entier absent du PRD** (une
limite de taille de fichier à 50 MB, avec message d'erreur littéral) — puis affirme dans sa
propre synthèse *"No concrete values are invented in Gherkin steps"*, une auto-contradiction
directe entre ce que Mistral fait et ce qu'il rapporte avoir fait. Contraste avec C13 et C16
du même lot où Mistral reste le plus rigoureux — le profil reste réel mais pas uniforme
d'un cas à l'autre.

**Groq échoue nettement sur C15 — rate le cas ciblé entièrement et se contredit
arithmétiquement sur son propre calcul.** Aucun scénario ne couvre la collision appel/
escalade citée en preuve dans le ticket (TS-4417) ; le seul point "contradiction" rapporté
est vague et ne correspond pas au vrai nœud. Le cahier annoncé à 8 scénarios n'en contient
que 6 (2 disparaissent sans trace). Pire : la synthèse affirme *"le ratio négatif est de 50 %,
ce qui est inférieur à l'objectif indicatif de 40 %"* — 50 % n'est PAS inférieur à 40 %, une
erreur logique sur sa propre phrase, pas seulement un mauvais comptage comme les occurrences
précédentes du pattern D20.

**Gemini confirme un profil positif inattendu : ratio D20 auto-rapporté exact sur 3/4 cas
de ce lot (C13, C14, C15).** Contraste net avec Groq/Mistral (faux sur la quasi-totalité de
leurs cas depuis le lot 1) — à ce stade du corpus, Gemini est le seul fournisseur dont
l'auto-décompte du ratio négatif s'avère systématiquement fiable quand vérifié
indépendamment, en plus d'être le fournisseur le plus complet sur les défauts ciblés
eux-mêmes (0 défaut ciblé raté sur les 16 cas où il a été disponible).

**5e cas consécutif de sans-faute total sur le défaut CRUD-inverse (C16), désormais un
signal établi plutôt qu'un résultat isolé** (C9 lot 4, puis C16) : tous les fournisseurs
disponibles, y compris Claude, flaguent systématiquement le trou plutôt que de l'inventer ou
de l'ignorer — la règle 3c d'`istqb-design` (D38) généralise fortement sur ce type précis de
défaut, contrairement aux contradictions et à la config-driven qui restent plus disputées.

**Confirmation transversale D20, encore (Groq C13/C14, Mistral C13/C15) — désormais établie
sur la quasi-totalité des cas où Groq/Mistral sont disponibles depuis le lot 1.**

## Lot 6 — 4 cas clean-room (C17-C20, DERNIER lot)

*Hugging Face indisponible sur les 4 cas (`402`, 8-9e échec consécutif depuis C10).*

| Cas | Sujet | Défaut ciblé | Claude | Gemini | Groq | Hugging Face | Mistral |
|---|---|---|---|---|---|---|---|
| C17 | HR-tech — recrutement, PII (nom/email/tel/salaire) | PII dans les exemples | ✅ | ✅ sans-faute, ratio exact (4e confirmation) | ⚠️ non concluant (n'engage jamais l'exemple) | indisponible (402) | ❌ **ledger complet, 4 catégories PII mappées d'un coup** |
| C18 | Voyage — annulation groupée, remboursement par ligne | Structurel C2 (`Then` non-vérifiable) | ✅ | ✅ (mais fabrique un seuil contredisant un "hors périmètre" explicite) | ❌ **3e gap outillage, aggravé** (restitutions de définition entières non captées) | indisponible (402) | ✅ (confusion statut ligne/dossier) |
| C19 | Immobilier — bail, collision rétractation/garant refusé (LC-2209) | Contradiction multi-règles | ✅ | ✅ la plus rigoureuse, ratio exact | ✅ faible (détection en surface, pas de vraie table de décision) | indisponible (402) | ✅ détection ok, mais **artefact encode l'inverse de sa propre synthèse** |
| C20 | Média — modération, Jira-ticket | Traçabilité/provenance (IDs) | ✅ | ✅ sans-faute, ratio exact | ✅ (couverture très mince, 7 scénarios vs 20-30 ailleurs) | indisponible (402) | ✅ IDs ok, mais fabrication non flaguée (SLA escalade) |

### Défauts trouvés (lot 6)

**Mistral échoue net une 2e fois sur la PII (C17) — pire que sa fuite du lot 2 (C2).** Le
canal narratif (section extraction) imprime explicitement les 4 catégories de PII d'un coup
("Name: Julien Castellano → [REDACTED:name]", idem email/téléphone/salaire) — un ledger complet
et systématique, pas une fuite isolée. Le cahier Gherkin généré reste propre, confirmant que
le risque réel se loge dans la narration du modèle, pas l'artefact final (nuance D59
maintenant confirmée sur 3 cas : C2, C7 partiellement, C17).

**3e occurrence, aggravée, du gap outillage `structural_score.py` (C18, Groq).** 6 des 10
`Then` de Groq sont des restitutions de définition complètes ("the total refund amount is the
sum of refunds for the cancelled lines" — aucun chiffre) qui échappent totalement à
`VAGUE_RE`/`ASSERT_RE` — le score baisse (72/CONCERNS) pour la bonne raison (`completeness`)
mais aucune ligne de `findings` ne nomme le vrai défaut ("Then non-vérifiable"), ce qui
induirait un relecteur humain lisant seulement les findings en erreur. 3 occurrences en 3
lots (C5 `VAGUE_RE`, C10 `HOLLOW_RE`, C18 `VAGUE_RE` aggravé) confirment que le détecteur a
un angle mort structurel sur les formulations paraphrasées, pas seulement des cas isolés.

**Mistral s'auto-contredit entre sa synthèse et son artefact exécutable (C19) — 2e
occurrence de ce type de défaut après Groq au lot 3 (C6).** La synthèse propose "priorité à
l'exception AC3 (remboursement)... à confirmer", mais le scénario Gherkin généré applique
l'inverse exact ("the system applies forfeiture instead of refund") sans le signaler comme
une divergence. Confirme que le risque de contradiction ne se limite pas au contenu source —
il peut aussi apparaître **entre les propres sorties du modèle**.

**3e cas consécutif de sans-faute quasi-total sur la traçabilité des IDs (C4, C12, C20)** —
avec Groq et le seul point de friction (couverture mince), jamais une omission/duplication
d'ID. Rejoint le CRUD-inverse (C9, C16) comme 2e catégorie de défaut qui généralise fortement
en profondeur, sans être un point faible réel du produit à ce stade (24 cas).

**Gemini termine le corpus à 0 défaut ciblé raté sur 24 cas disponibles (21/24, absent
seulement R2-R4 en lot 1)**, avec un ratio D20 auto-rapporté exact sur pratiquement tous les
cas où il a été mesuré — mais accumule 4 défauts annexes non ciblés sur l'ensemble du corpus
(codes HTTP fabriqués C7, mécanisme non flaggé C16, seuil contredisant un hors-périmètre
C18, erreur non flaggée C19) : jamais un échec de détection, mais pas non plus un
sans-faute absolu au sens large.

## Bilan global — corpus élargi 24/24 cas terminé

*Synthèse qualitative à partir des 6 lots (`eval/baselines/corpus-24-depth.md` ci-dessus).
Les comptages exacts par fournisseur n'ont pas été agrégés dans un script — chaque lot a été
jugé cas par cas par un agent indépendant avec citations, cette synthèse reste donc directionnelle,
pas un score statistique certifié.*

**Claude : 24/24 cas sans défaut de détection ciblé** (extraction/design/génération
appliqués fidèlement aux 3 skills sur chaque cas, vérifiés par grep/relecture à chaque fois).
Aucune régression trouvée sur aucun des 4 défauts patterns (contradiction, PII, config-driven,
structurel C1/C2) ni sur les 2 catégories neuves testées cette profondeur (CRUD-inverse,
traçabilité).

**Gemini : le fournisseur externe le plus fiable sur ce corpus.** 0 échec de détection ciblée
sur les 21 cas où il était disponible (rate-limité sur R2-R4 au lot 1), et le seul fournisseur
dont le ratio négatif D20 auto-rapporté s'est avéré systématiquement exact quand vérifié
indépendamment. Accumule néanmoins 4 défauts annexes de fabrication non flaguée répartis sur
le corpus — jamais sur le défaut ciblé lui-même, mais un signal à ne pas ignorer avant de le
considérer "sans-faute" au sens large.

**Groq : le profil le plus constant de raisonnement multi-règles superficiel.** Échoue le
défaut ciblé sur environ un quart à un tiers des cas où la tâche exige une reconstruction de
règles en collision ou un `Then` réellement vérifiable (R1 partiel, C1, C2, C3, C5, C6, C15,
C18) ; sans-faute sur les défauts de pure structure (CRUD-inverse, traçabilité). Le ratio
D20 auto-rapporté est faux sur la quasi-totalité des cas mesurés — souvent avec des erreurs
arithmétiques ou logiques visibles dans sa propre phrase (ex. "50 %, inférieur à 40 %").

**Mistral : un profil de fabrication/surconfiance récurrent mais pas systématique.** Échoue
le défaut ciblé sur environ un quart à un tiers des cas (R4, C3, C5, C6, C14, C17, partiellement
C2/C19), avec deux fuites PII narratives sérieuses (C2, C17) et plusieurs fabrications de
littéraux/mécanismes non flagués. Reste pourtant le plus rigoureux sur d'autres cas du même
lot (C9, C13, C16) — le profil est réel et répété, mais jamais uniforme sur 100 % des cas, ce
qui interdit un verdict "toujours mauvais sur X".

**Hugging Face : couverture partielle (13/24 cas), 6 défauts distincts trouvés dans les cas
mesurés, puis indisponibilité opérationnelle (crédit gratuit épuisé) sur la seconde moitié
du corpus.** Sur les 13 cas où il a tourné (R1-R4, C1-C9), montre le profil le plus dense de
défauts distincts (fuite PII, règle non appliquée, faux positif C1/C2, fabrication de codes
HTTP, résolution silencieuse de contradiction, fabrication de matrice/seuils) — mais rompt
aussi avec une série de 4 cas propres consécutifs (C6-C9) juste avant de devenir indisponible,
signal de variance non tranché faute de pouvoir continuer à le mesurer.

**2 défauts transversaux confirmés à l'échelle du corpus entier, indépendants du fournisseur
testé sur la cible :**
1. **Le ratio négatif D20 auto-rapporté est peu fiable** chez tous les fournisseurs sauf
   Gemini — confirmé sur plus de la moitié des 24 cas. Valide fortement la décision D50 de le
   recalculer de façon déterministe et indépendante dans `structural_score.py` plutôt que de
   faire confiance à l'auto-décompte d'un générateur, quel qu'il soit.
2. **`structural_score.py` a un angle mort structurel sur les formulations paraphrasées**
   (`VAGUE_RE`/`HOLLOW_RE`), confirmé 3 fois en 3 lots (C5, C10, C18) — gap outillage réel,
   non corrigé cette session, à traiter avant tout usage du détecteur C1/C2 en routine sur du
   contenu non-Claude.

**2 catégories de défaut testées pour la première fois cette profondeur généralisent
fortement (CRUD-inverse, traçabilité des IDs)** — quasi aucun échec sur ces deux points sur
l'ensemble du corpus, contrairement aux contradictions/PII/config-driven qui restent
disputées selon le fournisseur.

## Statut du corpus

**Terminé — 24/24 cas exécutés** (4 réels GitLab CE R1-R4 + 20 clean-room C1-C20, lots 1-6).
Reste non fait, identifié en cours de route mais hors scope de ce cycle : (1) corriger les 2
gaps `structural_score.py` (`VAGUE_RE`, `HOLLOW_RE`) ; (2) retenter Hugging Face en fin de
crédit si la session se poursuit, pour compléter sa couverture sur C10-C20 (11 cas jamais
mesurés pour ce fournisseur).
