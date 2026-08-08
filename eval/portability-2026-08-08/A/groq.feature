# Language: fr
# Feature: US-004

@QAIA-US-004-001 @P2 @state-transition
Scénario: Soumission d'un rapport en brouillon avec des données valides
Etant donné un rapport en brouillon avec des données valides
Lorsque je soumets le rapport
Alors la soumission est réussie

@QAIA-US-004-002 @P2 @state-transition
Scénario: Révision d'un rapport en attente de modification
Etant donné un rapport en attente de modification
Lorsque je modifie le rapport
Alors le rapport est mis à jour avec succès

@QAIA-US-004-003 @P2 @state-transition
Scénario: Révision d'un rapport en brouillon après une demande de modification
Etant donné un rapport en brouillon après une demande de modification
Lorsque je modifie le rapport
Alors le rapport est mis à jour avec succès

@QAIA-US-004-004 @P2 @state-transition @req-neg
Scénario: Soumission d'un rapport qui n'est pas en brouillon
Etant donné un rapport qui n'est pas en brouillon
Lorsque je soumets le rapport
Alors la soumission est refusée

@QAIA-US-004-005 @P2 @state-transition @req-neg
Scénario: Modification d'un rapport qui n'est pas en brouillon
Etant donné un rapport qui n'est pas en brouillon
Lorsque je modifie le rapport
Alors la modification est refusée

@QAIA-US-004-006 @P1 @state-transition @req-neg @low-confidence
Scénario: Rejet d'un rapport en brouillon
Etant donné un rapport en brouillon
Lorsque je rejette le rapport
Alors le rejet est refusé

@QAIA-US-004-007 @P1 @boundary
Scénario: Soumission d'un rapport avec un montant juste inférieur à 500 euros
Etant donné un rapport avec un montant juste inférieur à 500 euros
Lorsque je soumets le rapport
Alors la soumission est réussie

@QAIA-US-004-008 @P1 @boundary @req-neg-adjacent
Scénario: Soumission d'un rapport avec un montant exactement égal à 500 euros
Etant donné un rapport avec un montant exactement égal à 500 euros
Lorsque je soumets le rapport
Alors la soumission est refusée

@QAIA-US-004-009 @P1 @boundary @req-neg-adjacent
Scénario: Soumission d'un rapport avec un montant exactement égal à 5000 euros
Etant donné un rapport avec un montant exactement égal à 5000 euros
Lorsque je soumets le rapport
Alors la soumission est refusée

@QAIA-US-004-010 @P1 @boundary
Scénario: Soumission d'un rapport avec un montant supérieur à 5000 euros
Etant donné un rapport avec un montant supérieur à 5000 euros
Lorsque je soumets le rapport
Alors la soumission est réussie

@QAIA-US-004-011 @P1 @decision-table @req-neg
Scénario: Approbation d'un rapport par une personne non autorisée
Etant donné un rapport
Lorsque je demande l'approbation d'une personne non autorisée
Alors l'approbation est refusée

@QAIA-US-004-012 @P1 @decision-table @req-neg
Scénario: Auto-approbation d'un rapport
Etant donné un rapport
Lorsque je demande l'auto-approbation
Alors l'approbation est refusée

@QAIA-US-004-013 @P1 @decision-table @low-confidence
Scénario: Escalade de l'approbation d'un rapport
Etant donné un rapport
Lorsque je demande l'escalade de l'approbation
Alors l'approbation est déléguée à la personne suivante dans la chaîne d'approbation

@QAIA-US-004-014 @P1 @decision-table @low-confidence
Scénario: Escalade de l'approbation d'un rapport avec un montant supérieur à 5000 euros
Etant donné un rapport avec un montant supérieur à 5000 euros
Lorsque je demande l'escalade de l'approbation
Alors l'approbation est déléguée à la personne suivante dans la chaîne d'approbation

@QAIA-US-004-015 @P1 @decision-table @low-confidence
Scénario: Escalade de l'approbation d'un rapport avec un financeur
Etant donné un rapport avec un financeur
Lorsque je demande l'escalade de l'approbation
Alors l'approbation est déléguée à la personne suivante dans la chaîne d'approbation

@QAIA-US-004-016 @P2 @ep @req-neg
Scénario: Soumission d'un rapport avec une ligne manquante
Etant donné un rapport avec une ligne manquante
Lorsque je soumets le rapport
Alors la soumission est refusée

@QAIA-US-004-017 @P2 @boundary
Scénario: Soumission d'un rapport avec une ligne datée exactement 90 jours avant
Etant donné un rapport avec une ligne datée exactement 90 jours avant
Lorsque je soumets le rapport
Alors la soumission est réussie

@QAIA-US-004-018 @P2 @boundary @req-neg
Scénario: Soumission d'un rapport avec une ligne datée plus de 90 jours avant
Etant donné un rapport avec une ligne datée plus de 90 jours avant
Lorsque je soumets le rapport
Alors la soumission est refusée

@QAIA-US-004-019 @P2 @boundary
Scénario: Soumission d'un rapport avec une ligne dont le montant est juste inférieur à 25 euros
Etant donné un rapport avec une ligne dont le montant est juste inférieur à 25 euros
Lorsque je soumets le rapport
Alors la soumission est réussie

@QAIA-US-004-020 @P1 @boundary @req-neg
Scénario: Soumission d'un rapport avec une ligne dont le montant est exactement égal à 25 euros
Etant donné un rapport avec une ligne dont le montant est exactement égal à 25 euros
Lorsque je soumets le rapport
Alors la soumission est refusée

@QAIA-US-004-021 @P3 @ep
Scénario: Soumission d'un rapport avec une ligne dont le montant est supérieur à 25 euros
Etant donné un rapport avec une ligne dont le montant est supérieur à 25 euros
Lorsque je soumets le rapport
Alors la soumission est réussie

@QAIA-US-004-022 @P1 @boundary @req-neg @low-confidence
Scénario: Soumission d'un rapport avec une ligne dont le montant est inférieur à 25 euros et la devise n'est pas l'euro
Etant donné un rapport avec une ligne dont le montant est inférieur à 25 euros et la devise n'est pas l'euro
Lorsque je soumets le rapport
Alors la soumission est refusée

@QAIA-US-004-023 @P1 @ep
Scénario: Conversion d'un rapport en devise non-euro
Etant donné un rapport en devise non-euro
Lorsque je demande la conversion
Alors la conversion est réussie

@QAIA-US-004-024 @P1 @error-guessing @req-neg @low-confidence
Scénario: Soumission d'un rapport avec une devise non-euro et sans taux de change
Etant donné un rapport avec une devise non-euro
Lorsque je soumets le rapport sans taux de change
Alors la soumission est refusée

@QAIA-US-004-025 @P1 @error-guessing @low-confidence
Scénario: Soumission d'un rapport avec une devise non-euro et un taux de change obsolète
Etant donné un rapport avec une devise non-euro et un taux de change obsolète
Lorsque je soumets le rapport
Alors la soumission est réussie avec un avertissement de taux de change obsolète

@QAIA-US-004-026 @P1 @error-guessing @low-confidence
Scénario: Soumission d'un rapport avec une devise non-euro et un taux de change obsolète près d'un seuil de bande
Etant donné un rapport avec une devise non-euro et un taux de change obsolète près d'un seuil de bande
Lorsque je soumets le rapport
Alors la soumission est réussie avec un avertissement de taux de change obsolète

@QAIA-US-004-027 @P2 @state-transition @req-neg
Scénario: Réjection d'un rapport en attente de modification
Etant donné un rapport en attente de modification
Lorsque je rejette le rapport
Alors la réjection est refusée

@QAIA-US-004-028 @P2 @state-transition @req-neg
Scénario: Réjection d'un rapport en brouillon
Etant donné un rapport en brouillon
Lorsque je rejette le rapport
Alors la réjection est refusée

@QAIA-US-004-029 @P2 @boundary @req-neg
Scénario: Réjection d'un rapport sans commentaire
Etant donné un rapport
Lorsque je rejette le rapport sans commentaire
Alors la réjection est refusée

@QAIA-US-004-030 @P2 @boundary @req-neg
Scénario: Demande de modification d'un rapport sans commentaire
Etant donné un rapport
Lorsque je demande la modification du rapport sans commentaire
Alors la demande de modification est refusée

@QAIA-US-004-031 @P2 @boundary
Scénario: Réjection d'un rapport avec un commentaire d'exactement 10 caractères
Etant donné un rapport
Lorsque je rejette le rapport avec un commentaire d'exactement 10 caractères
Alors la réjection est réussie

@QAIA-US-004-032 @P3 @ep
Scénario: Approbation d'un rapport sans commentaire
Etant donné un rapport
Lorsque j'approuve le rapport sans commentaire
Alors l'approbation est réussie

@QAIA-US-004-033 @P1 @error-guessing
Scénario: Enregistrement de chaque transition dans l'historique des audits
Etant donné un rapport
Lorsque je souhaite enregistrer chaque transition dans l'historique des audits
Alors chaque transition est enregistrée avec succès

@QAIA-US-004-034 @P2 @error-guessing @req-neg
Scénario: Soumission d'un rapport sans authentification
Etant donné un rapport
Lorsque je soumets le rapport sans authentification
Alors la soumission est refusée

@QAIA-US-004-035 @P2 @error-guessing @req-neg
Scénario: Approbation d'un rapport sans authentification
Etant donné un rapport
Lorsque j'approuve le rapport sans authentification
Alors l'approbation est refusée

@QAIA-US-004-036 @P1 @error-guessing @req-neg
Scénario: Modification d'un rapport appartenant à une autre personne sans autorisation
Etant donné un rapport appartenant à une autre personne
Lorsque je modifie le rapport sans autorisation
Alors la modification est refusée

@QAIA-US-004-037 @P3 @ep
Scénario: Affichage d'un état vide pour les rapports d'une personne
Etant donné une personne avec aucun rapport
Lorsque je souhaite afficher les rapports de la personne
Alors un état vide est affiché