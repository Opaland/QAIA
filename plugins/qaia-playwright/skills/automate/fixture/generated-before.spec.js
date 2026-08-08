// A NAIVE generation output, deliberately built to contain one defect per class the
// self-review lint must catch: three trivial-assertion shapes, plus the three of the five
// measured classes that a static reader can see (a contradicted Then and a dropped ambiguity
// flag on the same test, and a test whose whole evidence is one-sided). This file is what a
// generation pass WITHOUT the self-review step could plausibly emit; it is never meant to be
// shipped or run in CI. See ./VALIDATION.md.
const { test, expect } = require('./fixtures');

test.describe('Booking cancellation window (fixture 041)', () => {

  // Violation A — tautological/reflexive comparison (step 5, bullet 1).
  // The scenario's Then names a concrete refusal message ("less than 4 hours"), but
  // the generated assertion checks nothing about the app at all.
  test('@QAIA-FIXTURE-041-001 @AC6 @P1 cancellation refused less than 4h before start', async ({ patient }) => {
    const { bookingPage } = patient;
    await bookingPage.book('s1'); // s1 = +3h
    const cancelBtn = bookingPage.appointments.getByRole('button', { name: 'Cancel' });
    await cancelBtn.click();
    expect(true).toBe(true); // <-- trivial: asserts a literal against itself
  });

  // Violation B — weak-by-construction matcher (step 5, bullet 3).
  // A Playwright locator handle from getByRole() is always a defined object even
  // when the element is not in the DOM (locators are lazy) — toBeDefined() here
  // proves nothing about whether the button is actually visible/enabled.
  test('@QAIA-FIXTURE-041-002 @AC6 @P1 cancel button is enabled once a slot is booked', async ({ patient }) => {
    const { bookingPage } = patient;
    await bookingPage.book('s5'); // s5 = +26h
    const cancelBtn = bookingPage.appointments.getByRole('button', { name: 'Cancel' });
    expect(cancelBtn).toBeDefined(); // <-- weak: always true for a locator handle
  });

  // Violation C — silent zero-assertion block (step 5, bullet 4).
  // The scenario has a concrete Then ("only dermatology slots are displayed"); the
  // generated test performs the action but never checks the outcome.
  test('@QAIA-FIXTURE-041-003 @AC1 @P2 specialty filter shows only matching practitioners', async ({ patient }) => {
    const { bookingPage } = patient;
    await bookingPage.filterBy('dermatology');
    // <-- no expect(...) at all: coverage promised by the Then, dropped in code
  });

  // Violation D5 -- an assertion that CONTRADICTS its own Then.
  // The Then demands the field be enabled, the same as for a registered address, precisely so
  // that nothing distinguishes the two cases. This asserts the opposite: that an unregistered
  // address leaves the field disabled -- i.e. it asserts the leak as the pass condition.
  // Measured on a real generated suite (US-EVAL-004, judged 4/12).
  test('@QAIA-FIXTURE-041-004 @AC7 @P1 an unregistered address gives no distinguishing signal', async ({ patient }) => {
    const { resetPage } = patient;
    await resetPage.submitEmail('nobody@example.test');
    expect(await resetPage.securityAnswer.isEnabled()).toBe(false); // <-- inverse of the Then
    // <-- and D6: the book marks this scenario as resting on an unanswered question; the code
    //     says nothing about it, so a red here will read as a regression
  });

  // Violation D7 -- the test's whole evidence is one-sided, and the second Then clause is gone.
  // `not.toBe(200)` is green whether the refusal is the one under test or any other, and the
  // clause "no cancellation appears in the booking history" is never asserted (that half is D9
  // once the report marks the row covered). Measured on US-EVAL-002 and US-EVAL-008.
  test('@QAIA-FIXTURE-041-005 @AC7 @P1 a cancellation without a reason is refused', async ({ patient }) => {
    const { api } = patient;
    const res = await api.cancel('s5', { reason: undefined });
    expect(res.status()).not.toBe(200); // <-- one-sided, unattributable
  });
});
