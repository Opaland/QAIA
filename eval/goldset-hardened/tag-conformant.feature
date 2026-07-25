# ACs: AC1,AC2,AC3
@QAIA-BILL-001 @AC1 @P1 @boundary
Scenario: Majoration MCS appliquée pour un patient de 80 ans ou plus
  Given un patient âgé de 82 ans suivi par un médecin non traitant en secteur 1
  When la facturation de la consultation est calculée
  Then le montant inclut la majoration MCS de 5.00 EUR

@QAIA-BILL-002 @AC2 @P2 @boundary
Scenario: Pas de majoration MCS sous le seuil d'âge
  Given un patient âgé de 79 ans en secteur 1
  When la facturation de la consultation est calculée
  Then le montant n'inclut pas la majoration MCS
  And le total est égal à 25.00 EUR

@QAIA-BILL-003 @AC3 @P1 @negative @decision-table
Scenario: Refus si secteur non autorisé
  Given un praticien en secteur non conventionné
  When la facturation est soumise
  Then la requête est rejetée avec le statut HTTP 422
