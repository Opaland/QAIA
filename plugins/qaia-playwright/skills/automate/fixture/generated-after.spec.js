// Fixture for issue #41 — the SAME generation, with SKILL.md step 5's self-review
// applied before writing: each trivial assertion replaced by a real one derived
// from its scenario's Then text, using the page object already in scope. See
// ../VALIDATION.md for the before → after mapping and why each fix was chosen.
const { test, expect } = require('./fixtures');

test.describe('Booking cancellation window (fixture 041)', () => {

  // Fix A — Then: 'the system refuses the cancellation and shows "less than 4 hours"'.
  // Was: expect(true).toBe(true). Now asserts the concrete message the Then names,
  // read from the page (bookingPage.message), same pattern as
  // examples/medibook/tests/e2e.booking.spec.js @QAIA-US-001-004.
  test('@QAIA-FIXTURE-041-001 @AC6 @P1 cancellation refused less than 4h before start', async ({ patient }) => {
    const { bookingPage } = patient;
    await bookingPage.book('s1'); // s1 = +3h
    const cancelBtn = bookingPage.appointments.getByRole('button', { name: 'Cancel' });
    await cancelBtn.click();
    await expect(bookingPage.message).toContainText('less than 4 hours');
  });

  // Fix B — Then: 'the cancel button is visible and enabled'.
  // Was: expect(cancelBtn).toBeDefined() (always true for a locator handle). Now
  // asserts the actual visible/enabled state the Then names.
  test('@QAIA-FIXTURE-041-002 @AC6 @P1 cancel button is enabled once a slot is booked', async ({ patient }) => {
    const { bookingPage } = patient;
    await bookingPage.book('s5'); // s5 = +26h
    const cancelBtn = bookingPage.appointments.getByRole('button', { name: 'Cancel' });
    await expect(cancelBtn).toBeVisible();
    await expect(cancelBtn).toBeEnabled();
  });

  // Fix C — Then: 'only dermatology slots are displayed'.
  // Was: no expect(...) at all. Now asserts the positive (dermatology present) and
  // the negative (cardiology absent) halves the Then actually names — matches
  // examples/medibook/tests/e2e.booking.spec.js @QAIA-US-001-001.
  test('@QAIA-FIXTURE-041-003 @AC1 @P2 specialty filter shows only matching practitioners', async ({ patient }) => {
    const { bookingPage } = patient;
    await bookingPage.filterBy('dermatology');
    await expect(bookingPage.slots.getByText('dermatology')).toHaveCount(1);
    await expect(bookingPage.slots.getByText('cardiology')).toHaveCount(0);
  });

  // Fix D5+D6 -- Then: 'the security question field is enabled, the same as for a registered
  // address'. Polarity restored, and the book's open question carried into the code so that a
  // red here reads as an answer rather than a regression.
  // open: Q1 -- unconfirmed reading, human arbitration pending. A failure of this test is the
  // answer to Q1 arriving, NOT a product regression: do not align the expected value with the app.
  test('@QAIA-FIXTURE-041-004 @AC7 @P1 @low-confidence an unregistered address gives no distinguishing signal', async ({ patient }) => {
    const { resetPage } = patient;
    // The Then claims SAMENESS between two cases, so the test must exercise both.
    await resetPage.submitEmail('registered@example.test');
    const enabledForKnown = await resetPage.securityAnswer.isEnabled();
    await resetPage.submitEmail('nobody@example.test');
    const enabledForUnknown = await resetPage.securityAnswer.isEnabled();
    expect(enabledForUnknown).toBe(enabledForKnown);
  });

  // Fix D7 -- both clauses of the Then asserted, and the refusal made attributable to the field
  // under test rather than to "not a success".
  test('@QAIA-FIXTURE-041-005 @AC7 @P1 @negative a cancellation without a reason is refused', async ({ patient }) => {
    const { api, bookingPage } = patient;
    const res = await api.cancel('s5', { reason: undefined });
    expect(res.status()).toBe(422);
    expect((await res.json()).error).toContain('reason');
    // "And no cancellation appears in the booking history" -- the clause a one-sided assertion drops.
    await expect(bookingPage.history.getByText('cancelled')).toHaveCount(0);
  });
});
