# ACs: AC1,AC2
@QAIA-BILL-001 @AC1
Scenario: Barème des majorations conforme au tableau
  Given un patient éligible aux majorations
  When la facturation est calculée
  Then les montants correspondent au tableau de l'image en annexe

@QAIA-BILL-002 @AC2
Scenario: Refus hors secteur
  Given un praticien en secteur non conventionné
  When la facturation est soumise
  Then la requête est rejetée avec le statut HTTP 422
