#!/usr/bin/env bash
# Post-push CI verification hook (async).
#
# Runs in the background after `git push`; wakes the model (exit 2) only if CI
# failed, is still pending after a bounded wait, or couldn't be found -- stays
# silent (exit 0) on a clean success or when it can't safely check (no token,
# not a GitHub remote, not the branch CI watches).
#
# Context: added 2026-07-30 after the "Lint Gherkin features" job broke
# silently across several commits and went unnoticed because no session
# re-checked CI status after pushing (see CLAUDE.md, commit 5c18a87).

set -u

TOKEN="${GITHUB_PERSONAL_ACCESS_TOKEN:-}"
[ -z "$TOKEN" ] && exit 0

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$ROOT" || exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
[ "$BRANCH" != "main" ] && exit 0

SHA=$(git rev-parse HEAD 2>/dev/null)
[ -z "$SHA" ] && exit 0

# HEAD must actually be on the remote before we ask GitHub about it. Without this the hook
# polls for 180s and then reports "aucun run trouve" for a commit the server has never seen --
# a false alarm on every local-only commit (observed twice on e4bfe9e, 2026-07-31). Repeated
# false alarms are how a CI watchdog gets ignored, which is the exact failure D124 created it
# to prevent.
git fetch --quiet origin 2>/dev/null || true
if ! git merge-base --is-ancestor "$SHA" origin/main 2>/dev/null; then
  exit 0
fi

REMOTE=$(git remote get-url origin 2>/dev/null)
REPO=$(echo "$REMOTE" | sed -E 's#.*github\.com[:/]+([^/]+/[^/.]+)(\.git)?$#\1#')
case "$REPO" in */*) ;; *) exit 0 ;; esac

MAX_WAIT=180
INTERVAL=8
ELAPSED=0
RUN_ID=""
STATUS=""
CONCLUSION=""

while [ "$ELAPSED" -lt "$MAX_WAIT" ]; do
  RESP=$(curl -sL -H "Authorization: Bearer $TOKEN" \
    "https://api.github.com/repos/$REPO/actions/runs?head_sha=$SHA&per_page=5" 2>/dev/null)
  RUN_ID=$(echo "$RESP" | grep -o '"id": *[0-9]*' | head -1 | grep -o '[0-9]*')
  if [ -n "$RUN_ID" ]; then
    STATUS=$(echo "$RESP" | grep -o '"status": *"[^"]*"' | head -1 | cut -d'"' -f4)
    CONCLUSION=$(echo "$RESP" | grep -o '"conclusion": *"[^"]*"' | head -1 | cut -d'"' -f4)
    [ "$STATUS" = "completed" ] && break
  fi
  sleep "$INTERVAL"
  ELAPSED=$((ELAPSED + INTERVAL))
done

if [ -z "$RUN_ID" ]; then
  echo "CI: aucun run GitHub Actions trouve pour $SHA sur main apres ${MAX_WAIT}s. Verifier manuellement : https://github.com/$REPO/actions"
  exit 2
elif [ "$STATUS" != "completed" ]; then
  echo "CI: run $RUN_ID pour $SHA toujours en cours apres ${MAX_WAIT}s (statut: $STATUS). Verifier plus tard : https://github.com/$REPO/actions/runs/$RUN_ID"
  exit 2
elif [ "$CONCLUSION" = "success" ]; then
  exit 0
else
  echo "CI EN ECHEC : run $RUN_ID pour $SHA -> conclusion \"$CONCLUSION\". Diagnostiquer avant de considerer la tache terminee : https://github.com/$REPO/actions/runs/$RUN_ID"
  exit 2
fi
