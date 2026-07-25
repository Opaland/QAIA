# Static demo — all 4 accounts verified (2026-07-26)

Confirmed live at `https://opaland.github.io/QAIA/` (GitHub Pages, Source: GitHub Actions,
`.github/workflows/pages.yml`). No browser automation tool was available in this environment
(Playwright MCP disconnected mid-session), so this was verified by running the exact deployed
`static-demo/mock-backend.js` file directly in Node — byte-identical to what the live page
loads, not a reimplementation — rather than clicking through the UI. A future session with
browser tooling should still do a visual pass (screenshots, actual click-through) as a
complementary check; this covers the logic, not the rendering.

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
