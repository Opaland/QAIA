# ACs: AC1,AC2
@QAIA-BILL-001 @AC1
Scenario: Appel du service de tarification
  Given le service de tarification sur http://tarif-prod-07.internal:8453
  When on POST la consultation avec le montant 137.50 EUR
  Then la réponse contient le code TARIF-9987
  And le statut est HTTP 200

@QAIA-BILL-002 @AC2
Scenario: Seuil de majoration
  Given un patient de [À DÉFINIR PAR LE TESTEUR] ans
  When la facturation est calculée
  Then le montant inclut la majoration TODO
