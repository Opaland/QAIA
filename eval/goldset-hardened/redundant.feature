# ACs: AC1
@QAIA-BILL-001 @AC1
Scenario: Majoration MCS appliquée pour un patient de 82 ans
  Given un patient âgé de 82 ans suivi par un médecin non traitant en secteur 1
  When la facturation de la consultation est calculée
  Then le montant inclut la majoration MCS de 5.00 EUR

@QAIA-BILL-002 @AC1
Scenario: Majoration MCS appliquée pour un patient de 85 ans
  Given un patient âgé de 85 ans suivi par un médecin non traitant en secteur 1
  When la facturation de la consultation est calculée
  Then le montant inclut la majoration MCS de 5.00 EUR

@QAIA-BILL-003 @AC1
Scenario: Majoration MCS appliquée pour un patient de 90 ans
  Given un patient âgé de 90 ans suivi par un médecin non traitant en secteur 1
  When la facturation de la consultation est calculée
  Then le montant inclut la majoration MCS de 5.00 EUR
