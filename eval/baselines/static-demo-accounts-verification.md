# Static demo — all 4 accounts verified (2026-07-26)

Confirmed live at `https://opaland.github.io/QAIA/` (GitHub Pages, Source: GitHub Actions,
`.github/workflows/pages.yml`). First pass (below, "Covered") was verified by running the exact
deployed `static-demo/mock-backend.js` file directly in Node — byte-identical to what the live
page loads — since the Playwright MCP tool was disconnected at the time.

**Update, same day**: Playwright MCP reconnected. Did the complementary real-browser pass this
was missing — actual navigation, form fills, clicks, screenshots (`static-demo-screenshots/
01-employee-signed-in.png` → `04-manager-approved.png`) against the live URL. Walked: employee
login → start draft → fill line (taxi, 40 EUR, receipt checked) → submit ("Report submitted
(total 40 EUR)") → sign out → manager login → inbox correctly lists the submitted report →
approve ("Decision recorded: approve") → inbox clears. Console monitored throughout
(`browser_console_messages`, all levels): **zero JS errors** across the whole interactive
session — the only console entry at all is a harmless `favicon.ico` 404 (no favicon file was
ever added to `static-demo/`, cosmetic only, not a functional defect). Confirms the Node-level
logic verification below matches actual rendered/interactive behavior, not just the underlying
code path.

## Covered

- All 4 demo accounts log in: `employee@demo`, `manager@demo`, `finance@demo`, `director@demo`
  (password `demo1234`).
- Band A report (employee submits, <500 EUR) → manager-only approval → `approved`.
- Band C report (employee submits, >5000 EUR) → full chain manager → finance → director, each
  approves in turn → `approved` only after all three.
- **Self-submission escalation**: manager submits their own band-A report → manager's own slot
  is replaced by finance (not just dropped) → manager gets `403 cannot approve your own report`
  on attempt, finance's approval alone fully closes it.
- **Director edge case**: director (top of hierarchy, no manager) submits a small report → still
  requires manager approval (manager isn't in `chainFor`'s exclusion, so the chain runs
  unmodified) — confirmed via manager's inbox actually listing it.
- Rejection with a comment → terminal `rejected`; a second decide attempt on the now-rejected
  report correctly 409s rather than accepting a second rejection.
- Changes-requested → returns to `draft`, re-editable.
- Read-path IDOR protection (D96 fix) holds throughout: verified again incidentally via the
  approver-only-sees-current-stage checks above (finance couldn't have read the report before
  manager's approval moved it into their scope — not re-tested explicitly here since
  `security-surface-risk-based-finding.md` already covers that specific case in depth).

No defects found in this pass — reported as a clean verification, not padded with an invented
gap.
