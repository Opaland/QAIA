# Instructions pour Claude — QAIA

## Toujours vérifier la CI après un `git push` vers `main`

Trouvé le 2026-07-30 : le job "Lint Gherkin features" était cassé en silence depuis plusieurs
commits (dossiers de fixtures ajoutés sans mettre à jour le scope du linter), jamais détecté
parce qu'aucune session n'avait revérifié l'état de la CI après avoir poussé.

**Règle** : après tout `git push` sur `main` (ou toute branche avec CI), attendre que le
workflow associé se termine et vérifier son statut avant de considérer la tâche terminée —
ne jamais supposer que la CI passe simplement parce que le push a réussi localement.

**Automatisé depuis le 2026-07-30** : un hook `PostToolUse` (`.claude/settings.json` +
`.claude/hooks/check-ci-after-push.sh`) se déclenche automatiquement après tout `git push`,
poll la CI en arrière-plan (jusqu'à 180s) et réveille l'agent uniquement si le run échoue,
reste bloqué, ou est introuvable — silencieux sur un succès. Nécessite
`GITHUB_PERSONAL_ACCESS_TOKEN` dans l'environnement (déjà présent dans les settings globaux
du fondateur) ; s'auto-désactive proprement si absent. Ne dispense pas de vérifier
manuellement (méthode ci-dessous) si le hook est indisponible ou désactivé.

Méthode manuelle de repli (pas de `gh` CLI disponible dans cet environnement) :
```bash
# Récupérer le run déclenché par le SHA qu'on vient de pousher
curl -sL -H "Authorization: Bearer $GITHUB_PERSONAL_ACCESS_TOKEN" \
  "https://api.github.com/repos/QAIA-Project/QAIA/actions/runs?head_sha=<SHA>"

# Une fois le run identifié, poller son statut (conclusion "success"/"failure")
curl -sL -H "Authorization: Bearer $GITHUB_PERSONAL_ACCESS_TOKEN" \
  "https://api.github.com/repos/QAIA-Project/QAIA/actions/runs/<RUN_ID>"

# Si échec, récupérer les logs du job pour diagnostiquer avant de clore la tâche :
curl -sL -H "Authorization: Bearer $GITHUB_PERSONAL_ACCESS_TOKEN" \
  "https://api.github.com/repos/QAIA-Project/QAIA/actions/jobs/<JOB_ID>/logs"
```

Si le run met du temps à démarrer/finir, utiliser `Monitor` (poll en arrière-plan, une
notification par événement) plutôt que d'attendre en bloquant le tour — ou signaler
explicitement à l'utilisateur qu'on n'a pas encore confirmé le vert avant de clore.
