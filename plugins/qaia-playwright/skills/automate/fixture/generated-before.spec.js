// Fixture for issue #41 — a NAIVE generation output, deliberately built to contain
// three trivial-assertion defects, one per class from SKILL.md step 4. This file is
// what a generation pass WITHOUT the self-review step could plausibly emit; it is
// never meant to be shipped or run in CI. See ../VALIDATION.md.
const { test, expect } = require('./fixtures');

test.describe('Booking cancellation window (fixture 041)', () => {

  // Violation A — tautological/reflexive comparison (step 4, bullet 1).
  // The scenario's Then names a concrete refusal message ("less than 4 hours"), but
  // the generated assertion checks nothing about the app at all.
  test('@QAIA-FIXTURE-041-001 @AC6 @P1 cancellation refused less than 4h before start', async ({ patient }) => {
    const { bookingPage } = patient;
    await bookingPage.book('s1'); // s1 = +3h
    const cancelBtn = bookingPage.appointments.getByRole('button', { name: 'Cancel' });
    await cancelBtn.click();
    expect(true).toBe(true); // <-- trivial: asserts a literal against itself
  });

  // Violation B — weak-by-construction matcher (step 4, bullet 3).
  // A Playwright locator handle from getByRole() is always a defined object even
  // when the element is not in the DOM (locators are lazy) — toBeDefined() here
  // proves nothing about whether the button is actually visible/enabled.
  test('@QAIA-FIXTURE-041-002 @AC6 @P1 cancel button is enabled once a slot is booked', async ({ patient }) => {
    const { bookingPage } = patient;
    await bookingPage.book('s5'); // s5 = +26h
    const cancelBtn = bookingPage.appointments.getByRole('button', { name: 'Cancel' });
    expect(cancelBtn).toBeDefined(); // <-- weak: always true for a locator handle
  });

  // Violation C — silent zero-assertion block (step 4, bullet 4).
  // The scenario has a concrete Then ("only dermatology slots are displayed"); the
  // generated test performs the action but never checks the outcome.
  test('@QAIA-FIXTURE-041-003 @AC1 @P2 specialty filter shows only matching practitioners', async ({ patient }) => {
    const { bookingPage } = patient;
    await bookingPage.filterBy('dermatology');
    // <-- no expect(...) at all: coverage promised by the Then, dropped in code
  });
});
