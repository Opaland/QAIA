# 01-extraction — US-EVAL-001

## Story

**As a** SauceDemo visitor,
**I want** the login page to correctly gate access based on my account's credentials and state,
**so that** only holders of valid, non-locked credentials ever reach the product catalog.

*(Not explicitly phrased as a story in the source — reconstructed from the captured behavior,
per `us-review` step 1: "As a/I want/So that — or 'not expressed in the source'".)*

## Acceptance criteria (numbered, stable — AC1..AC3)

- **AC1.** A user submitting the valid, non-locked credentials `standard_user` / `secret_sauce`
  is logged in and reaches the product catalog.
- **AC2.** A user submitting the valid but locked-out credentials `locked_out_user` /
  `secret_sauce` is refused login, shown the message "Sorry, this user has been locked out.",
  and does not reach the product catalog.
- **AC3.** A user submitting credentials that are not a recognized valid account (unknown
  username, or a known username with the wrong password) is refused login. *(Exact behavior/
  message not confirmed by any source found — see open point below.)*

## Business rules / constraints found outside the AC list

- `problem_user` and `performance_glitch_user` are valid, non-locked accounts (would satisfy
  AC1's login-success shape) but carry defects that surface only after login — out of scope for
  this US per the dependency noted in `00-source.md`.

## Referenced artifacts not analyzed

- None (no attachments/mockups in the source).

## Present but not classifiable

- None.

## What was NOT found

- No formal AC numbering in the source (none existed — this is a live-app capture, not a
  written ticket): numbering above is this skill's own reconstruction, not a re-numbering of an
  existing list.
- No stated behavior for the invalid-credentials case (username unknown / wrong password) —
  carried to `need-understanding` as an open point, not invented here.

## Journey

| Step | Status |
|---|---|
| 00-ingest | done |
| 01-review | done — ⚠ VALIDATION: `simulated: accepted-as-is` (non-interactive campaign run, no human reviewer at this micro-step; only the pre-automation gate is a hard human stop per the campaign prompt) |
