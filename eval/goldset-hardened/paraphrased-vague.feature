# ACs: AC1,AC2,AC3
# Regression fixture for the VAGUE_RE gap found in corpus-24-depth.md (C5 lot 3, C18 lot 6,
# D60/D63): a Then that restates a rule/formula in words, or hedges on an unnamed mechanism,
# without ever naming the resulting number/status, evaded the original narrow VAGUE_RE
# trigger-word list. Scenarios 1-2 below are paraphrased from the real Mistral/Groq outputs
# that slipped through; scenario 3 is a legitimate concrete assertion (must stay PASS);
# scenario 4 is a legitimate config-driven gap scenario tagged @low-confidence (must NOT be
# flagged vague — a hedge on an externally-configured value is correct behavior, not a defect).
# Scenario 5 (added #31, follow-up to D65/D71's documented residual limit) is the exact wording
# of C5/Mistral's SECOND Then (`the order between "P1" and "P2" is consistent (e.g., by player
# name)`) — quoted entity identifiers previously satisfied ASSERT_RE's blanket quote match and
# silenced the correct VAGUE_RE hit on "consistent"; must now also FAIL as C2.

@QAIA-BILL-001 @AC1
Scenario: Tie-break order between two patients with identical priority score
  Given deux patients avec un score de priorité identique
  When la liste d'attente est triée
  Then l'ordre entre les deux patients est départagé par une règle déterministe

@QAIA-BILL-002 @AC2
Scenario: Montant total du remboursement groupé
  Given trois lignes de remboursement partiel sur un même dossier
  When le remboursement groupé est calculé
  Then le montant total remboursé est la somme des remboursements des lignes annulées

@QAIA-BILL-003 @AC3
Scenario: Majoration MCS appliquée pour un patient de 82 ans
  Given un patient âgé de 82 ans suivi par un médecin non traitant en secteur 1
  When la facturation de la consultation est calculée
  Then le montant inclut la majoration MCS de 5.00 EUR

@QAIA-BILL-004 @AC1 @low-confidence
Scenario: Fenêtre de grâce pilotée par la configuration du cours
  Given un devoir dont la date d'échéance est dépassée
  When l'étudiant tente de soumettre son travail
  Then le comportement dépend de la configuration du cours (fenêtre de grâce non spécifiée)
  And le comportement par défaut sûr, en l'absence de configuration, est de refuser la soumission

@QAIA-BILL-005 @AC1
Scenario: Tie-break order between two named players, asserted only via cited identifiers
  Given two players tied on rating, losses and join date
  When the tie-break rule is applied to the seasonal ranking
  Then the order between "P1" and "P2" is consistent (e.g., by player name)
