// Proof that the generated dataset is actually injectable through a Playwright fixture and
// usable case-by-case by a generated test — not merely valid JSON. No app under test is
// needed here: this exercises the fixture-data layer (SKILL.md step 8).
const { test, expect } = require('./fixtures');

test.describe('US-EVAL-008 dataset — fixture injection', () => {
  test('the fixture exposes the parsed dataset', async ({ testData }) => {
    expect(testData._meta.usId).toBe('US-EVAL-008');
    expect(testData.cases.length).toBe(22);
  });

  test('a test can request a case by condition id instead of grep-hunting the fixture', async ({ testData }) => {
    const c = testData.cases.find((x) => x.coversCondition === 'AC4-C2' && x.expectedResult.status === 'pass');
    expect(c.id).toBe('C-009');
    const byId = Object.fromEntries(testData.cartItems.map((i) => [i.id, i]));
    const price = Object.fromEntries(testData.products.map((p) => [p.id, p.priceUsd]));
    const total = c.totalCheck.itemRefs.reduce((a, r) => a + price[byId[r].productId], 0);
    expect(total).toBe(1150);
  });

  test('every case resolves to concrete, injectable form input where the AC needs one', async ({ testData }) => {
    const formById = Object.fromEntries(testData.orderForms.map((f) => [f.id, f]));
    const needsForm = testData.cases.filter((c) => c.coversAC.some((a) => ['AC6', 'AC7', 'AC8', 'AC9'].includes(a)));
    expect(needsForm.length).toBeGreaterThan(0);
    for (const c of needsForm) {
      expect(formById[c.orderFormRef]).toBeTruthy();
      expect(typeof formById[c.orderFormRef].name).toBe('string');
      expect(typeof formById[c.orderFormRef].creditCard).toBe('string');
    }
  });

  test('the AC7-C3 whitespace boundary is exactly one space, not "some whitespace"', async ({ testData }) => {
    const c = testData.cases.find((x) => x.coversCondition === 'AC7-C3');
    const form = testData.orderForms.find((f) => f.id === c.orderFormRef);
    expect(form.creditCard).toBe(' ');
    expect(form.creditCard.length).toBe(1);
    expect(form.creditCard.charCodeAt(0)).toBe(32);
    expect(form.creditCard === '').toBe(false); // passes the target's `== ""` check
  });

  test('no person-like row leaks PII through the fixture', async ({ testData }) => {
    for (const s of testData.shoppers) {
      expect(s.synthetic).toBe(true);
      expect(s.email).toMatch(/@example\.invalid$/);
      expect(s.displayName).toMatch(/ Sample-\d+$/);
    }
  });

  test('the two [open] cases refuse to assert a side', async ({ testData }) => {
    const open = testData.cases.filter((c) => c.expectedResult.status === '[open]');
    expect(open.map((c) => c.id)).toEqual(['C-011', 'C-020']);
    for (const c of open) expect(c.expectedResult.interpretations.length).toBe(2);
  });
});
