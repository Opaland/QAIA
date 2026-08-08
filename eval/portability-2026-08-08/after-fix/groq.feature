# language: fr

Fonctionnalité: Gestion des dépenses
  # AC1-C1 : Soumission d'une dépense valide
  Scénario: Soumettre une dépense avec des données valides
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec des valeurs valides
    Alors la dépense est soumise avec succès

  # AC1-C2 : Révision d'une dépense
  Scénario: Réviser une dépense soumise
    Étant donné que je suis sur la page de révision de dépenses
    Lorsque je sélectionne une dépense soumise pour révision
    Alors la dépense est révisée avec succès

  # AC1-C3 : Ré-submission d'une dépense révisée
  Scénario: Ré-submission d'une dépense après révision
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je sélectionne une dépense révisée pour ré-submission
    Alors la dépense est ré-submise avec succès

  # AC1-C4 : [req-neg] Refus de soumission d'une dépense non valide
  Scénario: Soumettre une dépense avec des données non valides
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec des valeurs non valides
    Alors la soumission de la dépense est refusée

  # AC1-C5 : [req-neg] Refus de révision d'une dépense non soumise
  Scénario: Réviser une dépense non soumise
    Étant donné que je suis sur la page de révision de dépenses
    Lorsque je sélectionne une dépense non soumise pour révision
    Alors la révision de la dépense est refusée

  # AC1-C6 : [req-neg] Refus de rejet d'une dépense non soumise
  Scénario: Rejeter une dépense non soumise
    Étant donné que je suis sur la page de rejet de dépenses
    Lorsque je sélectionne une dépense non soumise pour rejet
    Alors le rejet de la dépense est refusé

  # AC2-C1 : Seuil de dépense inférieur à 500 €
  Scénario: Dépense inférieure à 500 €
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une valeur inférieure à 500 €
    Alors la dépense est soumise avec succès

  # AC2-C2 : Seuil de dépense égal à 500 €
  Scénario: Dépense égale à 500 €
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une valeur égale à 500 €
    Alors la dépense est soumise avec succès

  # AC2-C3 : Seuil de dépense égal à 5000 €
  Scénario: Dépense égale à 5000 €
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une valeur égale à 5000 €
    Alors la dépense est soumise avec succès

  # AC2-C4 : Seuil de dépense supérieur à 5000 €
  Scénario: Dépense supérieure à 5000 €
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une valeur supérieure à 5000 €
    Alors la dépense est soumise avec succès

  # AC2-C5 : [req-neg] Refus de dépense avec approbation non valide
  Scénario: Dépense avec approbation non valide
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une approbation non valide
    Alors la soumission de la dépense est refusée

  # AC3-C1 : [req-neg] Refus d'auto-approbation
  Scénario: Auto-approbation d'une dépense
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je sélectionne une dépense pour auto-approbation
    Alors l'auto-approbation est refusée

  # AC3-C2 : Escalade de l'approbation
  Scénario: Escalade de l'approbation d'une dépense
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je sélectionne une dépense pour escalade
    Alors l'approbation est escaladée avec succès

  # AC3-C3 : Escalade de l'approbation pour une dépense supérieure à 5000 €
  Scénario: Escalade de l'approbation pour une dépense supérieure à 5000 €
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je sélectionne une dépense supérieure à 5000 € pour escalade
    Alors l'approbation est escaladée avec succès

  # AC3-C4 : Escalade de l'approbation pour une dépense inférieure à 500 €
  Scénario: Escalade de l'approbation pour une dépense inférieure à 500 €
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je sélectionne une dépense inférieure à 500 € pour escalade
    Alors l'approbation est escaladée avec succès

  # AC4-C1 : [req-neg] Refus de dépense avec ligne manquante
  Scénario: Dépense avec ligne manquante
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une ligne manquante
    Alors la soumission de la dépense est refusée

  # AC4-C2 : Dépense avec ligne datée à 90 jours
  Scénario: Dépense avec ligne datée à 90 jours
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une ligne datée à 90 jours
    Alors la dépense est soumise avec succès

  # AC4-C3 : [req-neg] Refus de dépense avec ligne datée à plus de 90 jours
  Scénario: Dépense avec ligne datée à plus de 90 jours
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une ligne datée à plus de 90 jours
    Alors la soumission de la dépense est refusée

  # AC5-C1 : Dépense inférieure à 25 €
  Scénario: Dépense inférieure à 25 €
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une valeur inférieure à 25 €
    Alors la dépense est soumise avec succès

  # AC5-C2 : [req-neg] Refus de dépense égale à 25 € sans reçu
  Scénario: Dépense égale à 25 € sans reçu
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une valeur égale à 25 € sans reçu
    Alors la soumission de la dépense est refusée

  # AC5-C3 : Dépense supérieure à 25 € avec reçu
  Scénario: Dépense supérieure à 25 € avec reçu
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une valeur supérieure à 25 € avec reçu
    Alors la dépense est soumise avec succès

  # AC5-C4 : [req-neg] Refus de dépense non-EUR avec valeur équivalente à 25 €
  Scénario: Dépense non-EUR avec valeur équivalente à 25 €
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une valeur non-EUR équivalente à 25 €
    Alors la soumission de la dépense est refusée

  # AC6-C1 : Dépense en devise non-EUR
  Scénario: Dépense en devise non-EUR
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une devise non-EUR
    Alors la dépense est soumise avec succès

  # AC6-C2 : [req-neg] Refus de dépense en devise non-EUR sans taux de change
  Scénario: Dépense en devise non-EUR sans taux de change
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une devise non-EUR sans taux de change
    Alors la soumission de la dépense est refusée

  # AC6-C3 : Dépense en devise non-EUR avec taux de change
  Scénario: Dépense en devise non-EUR avec taux de change
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une devise non-EUR et un taux de change
    Alors la dépense est soumise avec succès

  # AC6-C4 : Dépense en devise non-EUR avec taux de change et escalade
  Scénario: Dépense en devise non-EUR avec taux de change et escalade
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec une devise non-EUR et un taux de change et une escalade
    Alors la dépense est soumise avec succès

  # AC7-C1 : [req-neg] Refus de révision de dépense rejetée
  Scénario: Révision de dépense rejetée
    Étant donné que je suis sur la page de révision de dépenses
    Lorsque je sélectionne une dépense rejetée pour révision
    Alors la révision de la dépense est refusée

  # AC7-C2 : [req-neg] Refus de rejet de dépense rejetée
  Scénario: Rejet de dépense rejetée
    Étant donné que je suis sur la page de rejet de dépenses
    Lorsque je sélectionne une dépense rejetée pour rejet
    Alors le rejet de la dépense est refusé

  # AC8-C1 : [req-neg] Refus de commentaire court
  Scénario: Commentaire court
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec un commentaire court
    Alors la soumission de la dépense est refusée

  # AC8-C2 : [req-neg] Refus de commentaire manquant
  Scénario: Commentaire manquant
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense sans commentaire
    Alors la soumission de la dépense est refusée

  # AC8-C3 : Commentaire de 10 caractères
  Scénario: Commentaire de 10 caractères
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je remplis les champs de dépense avec un commentaire de 10 caractères
    Alors la dépense est soumise avec succès

  # AC8-C4 : Approbation sans commentaire
  Scénario: Approbation sans commentaire
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je sélectionne une dépense pour approbation sans commentaire
    Alors l'approbation est effectuée avec succès

  # AC8-C5 : Traçabilité des transitions
  Scénario: Traçabilité des transitions
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je sélectionne une dépense pour transition
    Alors la transition est tracée avec succès

  # AC-auth-C1 : [req-neg] Refus d'accès non authentifié
  Scénario: Accès non authentifié
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je ne suis pas authentifié
    Alors l'accès est refusé

  # AC-auth-C2 : [req-neg] Refus de décision non authentifiée
  Scénario: Décision non authentifiée
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je ne suis pas authentifié pour prendre une décision
    Alors la décision est refusée

  # AC-auth-C3 : [req-neg] Refus d'accès non autorisé
  Scénario: Accès non autorisé
    Étant donné que je suis sur la page de soumission de dépenses
    Lorsque je n'ai pas les autorisations nécessaires
    Alors l'accès est refusé

  # AC-list-C1 : Liste de dépenses vide
  Scénario: Liste de dépenses vide
    Étant donné que je suis sur la page de liste de dépenses
    Lorsque je n'ai aucune dépense
    Alors la liste est vide avec succès