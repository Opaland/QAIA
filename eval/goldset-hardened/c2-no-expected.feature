# ACs: AC1,AC2
@QAIA-BILL-001 @AC1
Scenario: Calcul de la facturation
  Given un patient de 82 ans
  When la facturation est calculée
  Then le système répond correctement

@QAIA-BILL-002 @AC2
Scenario: Soumission de la facture
  Given une facture valide
  When elle est soumise
  Then cela fonctionne comme attendu
