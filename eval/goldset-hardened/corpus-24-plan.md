# Corpus élargi — 24 cas, profondeur statistique (2026-07-24 ter, suite 13)

Objectif : voir si les 4 patterns trouvés en N=1 par skill (Groq/raisonnement profond,
Hugging Face/fiabilité d'exécution, Mistral/traçabilité, structurel C1/C2) tiennent à N=20+.
Chaque cas est testé sur Claude + Gemini + Groq + Hugging Face + Mistral.

## Sources réelles (4) — GitLab CE v8.16.9, jamais utilisées cette session

| # | Source réelle | Domaine | Défaut ciblé |
|---|---|---|---|
| R1 | `features/project/milestone.feature` (listing labels via un jalon) | DevOps | Liste/agrégation, redondance |
| R2 | `features/project/labels.feature` (subscribe/unsubscribe à un label) | DevOps | CRUD-inverse, confiance sur le mécanisme |
| R3 | `features/project/create.feature` (création avec précondition clé SSH) | DevOps | Ambiguïté config-driven (précondition) |
| R4 | `features/explore/projects.feature` (matrice public/interne/privé/archivé × anon/auth) | DevOps | Autorisation multi-axes, table de décision |

## Cas clean-room (20) — répartis par format et domaine

| # | Format | Domaine | Défaut ciblé |
|---|---|---|---|
| C1 | US narrative | Fintech (virement) | Contradiction multi-règles (triple-AC) |
| C2 | PRD | Logistique (suivi colis) | PII (adresse/téléphone client exemple) |
| C3 | Spec/RFC | Santé (dossier patient) | Ambiguïté config-driven |
| C4 | Jira-ticket | EdTech (notes d'examen) | Traçabilité/provenance (manifeste) |
| C5 | US narrative | Gaming (classement) | Structurel C2 (Then non-vérifiable) |
| C6 | PRD | IoT/domotique (règles d'automatisation) | Contradiction multi-règles |
| C7 | Spec/RFC | HR-tech (congés) | PII (données RH) |
| C8 | Jira-ticket | Voyage (réservation) | Config-driven (tarification dynamique) |
| C9 | US narrative | Immobilier (visites) | CRUD-inverse (annulation) |
| C10 | PRD | Média/streaming (recommandations) | Structurel C1 (preuve externe) |
| C11 | Spec/RFC | Fintech (KYC) | Contradiction multi-règles |
| C12 | Jira-ticket | Logistique (retours) | Traçabilité/provenance |
| C13 | US narrative | Santé (rendez-vous) | PII |
| C14 | PRD | EdTech (devoirs) | Config-driven |
| C15 | Spec/RFC | Gaming (anti-triche) | Contradiction multi-règles |
| C16 | Jira-ticket | IoT (notifications) | CRUD-inverse |
| C17 | US narrative | HR-tech (recrutement) | PII |
| C18 | PRD | Voyage (annulation groupée) | Structurel C2 |
| C19 | Spec/RFC | Immobilier (contrats) | Contradiction multi-règles |
| C20 | Jira-ticket | Média (modération) | Traçabilité/provenance |

## Protocole d'exécution

Par cas : 1 ticket dur (terse, sans liste d'AC explicite) → extraction + design + génération
(règles condensées identiques au protocole #24), testé sur Claude (agent) + Gemini/Groq/HF/
Mistral (appel direct). Résultats agrégés dans `eval/baselines/corpus-24-depth.md` par lot de
4-6 cas pour respecter les limites de débit gratuites (Gemini a déjà montré un 429 après
~15-20 appels dans une session).

**Statut** : **TERMINÉ — 24/24 cas exécutés** (R1-R4 réels + C1-C20 clean-room, lots 1-6).
Détail, défauts trouvés et bilan global : `eval/baselines/corpus-24-depth.md`, décisions
D58-D64 dans `docs/DECISIONS.md`.
