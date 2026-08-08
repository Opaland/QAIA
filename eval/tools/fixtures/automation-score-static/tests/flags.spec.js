// Fixture for the two static checks added 2026-08-08, both derived from defects that four
// blank-context judges found by hand before any machine could see them.
//
// Expected findings when automation_score.py runs here:
//   FIX-001 -> flag-dropped (BLOCKING)        the book flags it, the code says nothing
//   FIX-002 -> nothing                         not flagged, nothing to carry
//   FIX-003 -> single-sided-evidence           its whole evidence is "not the success value"
//   FIX-004 -> nothing                         flagged in the book AND carried in the code
const { test, expect } = require('@playwright/test');

test('@QAIA-FIX-001 @P1 a flagged scenario whose test drops the flag', async () => {
  // No mention of the open question anywhere: a red here reads as a regression.
  expect(200).toBe(200);
});

test('@QAIA-FIX-002 @P2 an unflagged scenario', async () => {
  expect(200).toBe(200);
});

test('@QAIA-FIX-003 @P1 a refusal asserted only by what it is not', async () => {
  const status = 422;
  expect(status).not.toBe(200);
});

test('@QAIA-FIX-004 @P2 a flagged scenario that carries its flag', async () => {
  // open: Q1 -- unconfirmed reading, human arbitration pending. A failure here is an answer,
  // not a bug.
  expect(200).toBe(200);
});
