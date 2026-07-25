// Fixture for issue #41 — the SAME generation, with SKILL.md step 4's self-review
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
});
