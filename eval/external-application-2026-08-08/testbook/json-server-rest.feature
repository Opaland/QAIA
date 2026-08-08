# Cahier de tests -- json-server, API REST documentee
#
# SOURCE D'EXIGENCE, UNIQUE ET EXTERNE : le README.md du depot `typicode/json-server` au
# commit 8fb0f72 (2024-05-13). Aucune autre source. Ni le code, ni les tests du projet, ni les
# tickets, ni les commits de correction n'ont ete lus avant la generation de ce cahier.
#
# Ce cahier n'a pas ete ecrit pour attraper un defaut connu : il a ete ecrit pour couvrir un
# contrat publie. C'est la seule facon dont le resultat signifie quelque chose.
#
# Questions ouvertes -- le README ne les tranche pas. Elles sont marquees dans les scenarios
# concernes par `# open: Qn` et AUCUNE n'est resolue par supposition (ADR 0001 : une ambiguite se
# declare, elle ne se devine pas).
#
#   Q1  Les operateurs sont listes `lt`, `lte`, `gt`, `gte`, `ne` mais l'exemple ecrit
#       `?views_gt=9000`. Le prefixe est-il le nom du champ ou un underscore autonome ?
#       Retenu pour les scenarios : `champ_op`, la seule forme montree par un exemple.
#   Q2  La pagination est listee `page`, `per_page` et montree `_page`, `_per_page`. Idem pour
#       la plage : listee `start`, `end`, `limit`, montree `_start`, `_end`, `_limit`.
#       Retenu : la forme des exemples.
#   Q3  **La forme de la reponse paginee n'est documentee nulle part.** Un tableau ? une
#       enveloppe avec un total ? Aucun scenario n'asserte la forme : ce serait inventer
#       l'exigence.
#   Q4  **Aucun code de statut n'est documente, pour aucune route.** Ni le succes, ni l'absence,
#       ni l'invalide. Les scenarios ci-dessous n'assertent donc un code que la ou le README
#       promet un comportement observable autrement (corps de reponse, effet sur les donnees).
#   Q5  `_per_page` a pour defaut 10. Le comportement au-dela de la derniere page n'est pas dit.
#   Q6  `_embed=post` (singulier) est montre pour `comments` sans que la regle de nommage
#       -- pluriel vers singulier, cle etrangere `postId` -- soit enoncee.
#   Q7  `_dependent=comments` supprime les dependances ; la reponse et le sort des dependances
#       orphelines si la ressource parente n'existe pas ne sont pas dits.
#
# Base de donnees de reference : celle publiee dans le README (posts avec `views` 100 et 200,
# deux comments rattaches au post 1, un objet singulier `profile`).

Fonctionnalite: Servir une base JSON comme une API REST

  Contexte:
    Etant donne une base contenant les posts 1 (views 100) et 2 (views 200)
    Et deux commentaires rattaches au post 1
    Et un objet singulier profile

  # --- Routes de collection et d'element -------------------------------------------------

  @QAIA-EXT-001 @routes @P1
  Scenario: La collection entiere est renvoyee
    Quand je demande GET /posts
    Alors je recois les deux posts, 1 et 2

  @QAIA-EXT-002 @routes @P1
  Scenario: Un element est renvoye par son identifiant
    Quand je demande GET /posts/1
    Alors je recois le post 1 et son titre "a title"

  @QAIA-EXT-003 @routes @P1 @negatif
  Scenario: Un identifiant inexistant ne renvoie pas de ressource
    # open: Q4 -- le README ne dit pas quel code. L'assertion porte sur ce qu'il promet :
    # il n'existe pas de post 999, donc la reponse ne peut pas etre un post 999.
    Quand je demande GET /posts/999
    Alors la reponse ne contient pas de ressource d'identifiant 999

  @QAIA-EXT-004 @routes @P1 @negatif
  Scenario: Une collection inexistante ne renvoie pas de donnees
    Quand je demande GET /inexistant
    Alors la reponse ne contient aucune ressource

  @QAIA-EXT-005 @routes @P1
  Scenario: L'objet singulier profile est lisible
    Quand je demande GET /profile
    Alors je recois un objet dont le nom est "typicode"

  # --- Ecriture ---------------------------------------------------------------------------

  @QAIA-EXT-006 @ecriture @P1
  Scenario: Un identifiant est genere quand il manque
    # README, "Notable differences" : « id is always a string and will be generated for you if missing »
    Quand je cree un post sans identifiant
    Alors la ressource creee porte un identifiant
    Et cet identifiant est une chaine de caracteres

  @QAIA-EXT-007 @ecriture @P1
  Scenario: L'identifiant est toujours une chaine
    Quand je demande GET /posts
    Alors l'identifiant de chaque post est une chaine de caracteres

  @QAIA-EXT-008 @ecriture @P1
  Scenario: PUT remplace la ressource
    Quand je remplace le post 1 par un titre "remplace"
    Et que je demande GET /posts/1
    Alors le titre du post 1 est "remplace"

  @QAIA-EXT-009 @ecriture @P1
  Scenario: PATCH modifie un seul champ et conserve les autres
    Quand je modifie le seul titre du post 2 en "patche"
    Et que je demande GET /posts/2
    Alors le titre du post 2 est "patche"
    Et le nombre de vues du post 2 vaut toujours 200

  @QAIA-EXT-010 @ecriture @P1
  Scenario: DELETE retire la ressource
    Quand je supprime le post 2
    Et que je demande GET /posts
    Alors le post 2 n'est plus dans la collection

  @QAIA-EXT-011 @ecriture @P1
  Scenario: PATCH sur l'objet singulier profile
    Quand je modifie le profil avec le nom "modifie"
    Et que je demande GET /profile
    Alors le nom du profil est "modifie"

  # --- Conditions -------------------------------------------------------------------------

  @QAIA-EXT-012 @conditions @P1
  Scenario: Egalite implicite sur un champ
    # README : « ` ` -> `==` »
    Quand je demande GET /posts?views=200
    Alors je recois le seul post 2

  @QAIA-EXT-013 @conditions @P1
  Scenario: Superieur strict
    Quand je demande GET /posts?views_gt=100
    Alors je recois le seul post 2

  @QAIA-EXT-014 @conditions @P1 @limite
  Scenario: Superieur strict exclut la valeur exacte
    # Valeur limite : 100 est la valeur exacte d'un post, elle doit etre exclue par `gt`.
    Quand je demande GET /posts?views_gt=200
    Alors je ne recois aucun post

  @QAIA-EXT-015 @conditions @P1 @limite
  Scenario: Superieur ou egal inclut la valeur exacte
    Quand je demande GET /posts?views_gte=200
    Alors je recois le seul post 2

  @QAIA-EXT-016 @conditions @P1
  Scenario: Inferieur strict
    Quand je demande GET /posts?views_lt=200
    Alors je recois le seul post 1

  @QAIA-EXT-017 @conditions @P1 @limite
  Scenario: Inferieur ou egal inclut la valeur exacte
    Quand je demande GET /posts?views_lte=100
    Alors je recois le seul post 1

  @QAIA-EXT-018 @conditions @P1 @negatif
  Scenario: Different exclut la valeur donnee
    Quand je demande GET /posts?views_ne=100
    Alors je recois le seul post 2

  @QAIA-EXT-019 @conditions @P1
  Scenario: Deux conditions sur le meme champ se combinent
    # Le README documente les operateurs sans interdire de les cumuler ; deux bornes qui
    # encadrent le seul post 2 sont la lecture la plus faible qu'on puisse en faire.
    Quand je demande GET /posts?views_gt=100&views_lt=300
    Alors je recois le seul post 2

  @QAIA-EXT-020 @conditions @P1
  Scenario: Une condition sur un champ absent ne renvoie rien
    Quand je demande GET /posts?champ_absent=valeur
    Alors je ne recois aucun post

  # --- Plage ------------------------------------------------------------------------------

  @QAIA-EXT-021 @plage @P1
  Scenario: _limit borne le nombre d'elements
    Quand je demande GET /posts?_limit=1
    Alors je recois exactement un post

  @QAIA-EXT-022 @plage @P1
  Scenario: _start decale le debut
    Quand je demande GET /posts?_start=1
    Alors je recois exactement un post
    Et ce post est le post 2

  @QAIA-EXT-023 @plage @P1 @limite
  Scenario: _start et _end delimitent une tranche
    Quand je demande GET /posts?_start=0&_end=1
    Alors je recois exactement un post
    Et ce post est le post 1

  # --- Pagination -------------------------------------------------------------------------

  @QAIA-EXT-024 @pagination @P1
  Scenario: Une page de taille 1 ne contient qu'un element
    # open: Q3 -- la forme de la reponse n'est pas documentee, donc l'assertion porte sur le
    # nombre d'elements de donnees, quelle que soit l'enveloppe qui les porte.
    Quand je demande GET /posts?_page=1&_per_page=1
    Alors la reponse porte exactement un post

  @QAIA-EXT-025 @pagination @P1
  Scenario: La deuxieme page contient l'element suivant
    Quand je demande GET /posts?_page=2&_per_page=1
    Alors la reponse porte exactement un post
    Et ce post est le post 2

  # --- Tri --------------------------------------------------------------------------------

  @QAIA-EXT-026 @tri @P1
  Scenario: Tri ascendant sur un champ numerique
    Quand je demande GET /posts?_sort=views
    Alors les posts arrivent dans l'ordre 1 puis 2

  @QAIA-EXT-027 @tri @P1
  Scenario: Le prefixe moins inverse le tri
    # README : `_sort=id,-views`
    Quand je demande GET /posts?_sort=-views
    Alors les posts arrivent dans l'ordre 2 puis 1

  # --- Embed ------------------------------------------------------------------------------

  @QAIA-EXT-028 @embed @P1
  Scenario: Un post embarque ses commentaires
    Quand je demande GET /posts?_embed=comments
    Alors le post 1 porte ses deux commentaires

  @QAIA-EXT-029 @embed @P1
  Scenario: Un commentaire embarque son post
    # open: Q6 -- la regle de nommage n'est pas enoncee, seul l'exemple l'est.
    Quand je demande GET /comments?_embed=post
    Alors chaque commentaire porte le post 1

  # --- Suppression en cascade ---------------------------------------------------------------

  @QAIA-EXT-030 @suppression @P1
  Scenario: _dependent supprime les ressources dependantes
    Quand je supprime le post 1 avec _dependent=comments
    Et que je demande GET /comments
    Alors il ne reste aucun commentaire rattache au post 1

  # --- Champs imbriques -----------------------------------------------------------------------

  @QAIA-EXT-031 @imbrique @P2
  Scenario: Filtrer sur un champ imbrique
    # README : `GET /foo?a.b=bar`
    Etant donne une ressource foo dont a.b vaut "bar"
    Quand je demande GET /foo?a.b=bar
    Alors je recois cette ressource

  @QAIA-EXT-032 @imbrique @P2
  Scenario: Filtrer sur un element de tableau par son indice
    # README : `GET /foo?arr[0]=bar`
    Etant donne une ressource foo dont arr[0] vaut "bar"
    Quand je demande GET /foo?arr[0]=bar
    Alors je recois cette ressource
