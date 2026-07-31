// Property-by-property verification of the dataset produced by
// plugins/qaia-testdata/skills/dataset-generate/SKILL.md, consumed through the fixture pattern
// the skill's own step 8 documents. Each test names the SKILL.md step/guardrail it checks.
const { test, expect } = require('./fixtures');

// ---------------------------------------------------------------- step 7 (_meta)
test('P1 - step 7: _meta carries US-ID, generation date, disclaimer and assumptions[]', async ({ testData }) => {
  expect(testData._meta.usId).toBe('US-EVAL-008');
  expect(testData._meta.generatedAt).toBeTruthy();
  expect(testData._meta.disclaimer.length).toBeGreaterThan(80);
  expect(Array.isArray(testData._meta.assumptions)).toBe(true);
  expect(testData._meta.assumptions.length).toBeGreaterThan(0);
  for (const a of testData._meta.assumptions) {
    expect(a.id).toMatch(/^ASM-\d+$/);
    expect(a.text.length).toBeGreaterThan(40);
  }
});

// ---------------------------------------------------------------- uniqueness (NOT promised by SKILL.md - checked anyway)
test('P2 - every id in every entity array is unique (property NOT promised by SKILL.md)', async ({ testData }) => {
  const arrays = ['products', 'shoppers', 'cartItems', 'carts', 'apiResponses', 'orderForms', 'cases'];
  const allIds = [];
  for (const name of arrays) {
    const ids = testData[name].map((r) => r.id);
    expect(new Set(ids).size, `duplicate id inside ${name}`).toBe(ids.length);
    allIds.push(...ids);
  }
  // cross-array uniqueness too (prefix discipline)
  expect(new Set(allIds).size).toBe(allIds.length);
  // externally-visible business ids must be unique as well
  const prodIds = testData.products.map((p) => p.prodId);
  expect(new Set(prodIds).size).toBe(prodIds.length);
  const cartItemIds = testData.cartItems.map((c) => c.cartItemId);
  expect(new Set(cartItemIds).size).toBe(cartItemIds.length);
});

// ---------------------------------------------------------------- step 4 (referential integrity)
test('P3 - step 4: every foreign key resolves', async ({ testData }) => {
  const productIds = new Set(testData.products.map((p) => p.id));
  const shopperIds = new Set(testData.shoppers.map((s) => s.id));
  const cartIds = new Set(testData.carts.map((c) => c.id));
  const itemIds = new Set(testData.cartItems.map((c) => c.id));
  const apiIds = new Set(testData.apiResponses.map((a) => a.id));
  const formIds = new Set(testData.orderForms.map((f) => f.id));

  for (const ci of testData.cartItems) {
    expect(productIds.has(ci.productId), `${ci.id} -> ${ci.productId}`).toBe(true);
    expect(shopperIds.has(ci.shopperId), `${ci.id} -> ${ci.shopperId}`).toBe(true);
    expect(cartIds.has(ci.cartId), `${ci.id} -> ${ci.cartId}`).toBe(true);
  }
  for (const cart of testData.carts) {
    expect(shopperIds.has(cart.shopperId)).toBe(true);
    for (const ref of cart.itemRefs) expect(itemIds.has(ref), `${cart.id} -> ${ref}`).toBe(true);
    // a cart's items must all actually belong to that cart (no cross-wiring)
    for (const ref of cart.itemRefs) {
      const ci = testData.cartItems.find((x) => x.id === ref);
      expect(ci.cartId).toBe(cart.id);
      expect(ci.shopperId).toBe(cart.shopperId);
    }
  }
  for (const c of testData.cases) {
    if (c.cartId) expect(cartIds.has(c.cartId), `${c.id} -> ${c.cartId}`).toBe(true);
    if (c.shopperId) expect(shopperIds.has(c.shopperId), `${c.id} -> ${c.shopperId}`).toBe(true);
    if (c.productId) expect(productIds.has(c.productId), `${c.id} -> ${c.productId}`).toBe(true);
    if (c.apiResponseId) expect(apiIds.has(c.apiResponseId), `${c.id} -> ${c.apiResponseId}`).toBe(true);
    if (c.orderFormId) expect(formIds.has(c.orderFormId), `${c.id} -> ${c.orderFormId}`).toBe(true);
    if (c.alternateOrderFormId) expect(formIds.has(c.alternateOrderFormId)).toBe(true);
    if (c.cartItemId) expect(itemIds.has(c.cartItemId), `${c.id} -> ${c.cartItemId}`).toBe(true);
  }
});

// ---------------------------------------------------------------- step 4 (recompute, don't eyeball)
test('P4 - step 4: every cart total is RECOMPUTED from its rows, not trusted', async ({ testData }) => {
  const priceOf = (itemRef) => {
    const ci = testData.cartItems.find((x) => x.id === itemRef);
    return testData.products.find((p) => p.id === ci.productId).price;
  };
  for (const cart of testData.carts) {
    const prices = cart.itemRefs.map(priceOf);
    const parseIntSum = prices.reduce((a, b) => a + parseInt(String(b), 10), 0);
    if (cart.expectedTotal !== null) {
      expect(parseIntSum, `${cart.id} recomputed total`).toBe(cart.expectedTotal);
      // and no non-integer price hides inside a cart that claims an exact total
      for (const p of prices) expect(Number.isInteger(p)).toBe(true);
    } else {
      // the deliberately-unresolved cart: both stated sums must be the real ones
      expect(parseIntSum).toBe(cart.expectedTotalParseIntSum);
      const arithmetic = Math.round(prices.reduce((a, b) => a + b, 0) * 100) / 100;
      expect(arithmetic).toBe(cart.expectedTotalArithmeticSum);
      expect(parseIntSum).not.toBe(arithmetic); // the fork is real, not cosmetic
    }
  }
});

test('P5 - step 4: the post-delete total in C-011 is recomputed from the surviving rows', async ({ testData }) => {
  const c = testData.cases.find((x) => x.id === 'C-011');
  const cart = testData.carts.find((x) => x.id === c.cartId);
  const surviving = cart.itemRefs.filter((r) => r !== c.cartItemId);
  const total = surviving.reduce((sum, ref) => {
    const ci = testData.cartItems.find((x) => x.id === ref);
    return sum + testData.products.find((p) => p.id === ci.productId).price;
  }, 0);
  expect(total).toBe(c.expectedTotalAfterDelete);
});

// ---------------------------------------------------------------- step 6 / guardrail 1 (no PII)
test('P6 - step 6: every person-like row is synthetic, Sample-NN named, @example.invalid mailed', async ({ testData }) => {
  expect(testData.shoppers.length).toBeGreaterThan(0);
  for (const s of testData.shoppers) {
    expect(s.synthetic, `${s.id} missing synthetic:true`).toBe(true);
    expect(s.name, `${s.id} name`).toMatch(/ Sample-\d{2}$/);
    expect(s.email, `${s.id} email`).toMatch(/@example\.invalid$/);
  }
  // order forms carry a person name too - it must be one of the synthetic shoppers, or empty
  const names = new Set(testData.shoppers.map((s) => s.name));
  for (const f of testData.orderForms) {
    if (f.name !== '') expect(names.has(f.name), `${f.id} name '${f.name}' is not a synthetic shopper`).toBe(true);
  }
});

test('P7 - step 6: no value anywhere in the file looks like a real e-mail, PAN, or real-world domain', async ({ testData }) => {
  const raw = JSON.stringify(testData);
  // any e-mail-shaped literal must use the RFC 2606 reserved TLD
  const emails = raw.match(/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/g) || [];
  expect(emails.length).toBeGreaterThan(0);
  for (const e of emails) expect(e, 'non-reserved e-mail domain').toMatch(/@example\.(invalid|com|org|net)$/);
  // no 13-19 digit run anywhere (a PAN-shaped literal)
  const pans = raw.match(/\d{13,19}/g) || [];
  expect(pans, `PAN-shaped literal(s) found: ${JSON.stringify(pans)}`).toEqual([]);
  // card fields specifically must be non-numeric or empty/whitespace
  for (const f of testData.orderForms) {
    expect(/^\s*$|^CARD-SAMPLE-/.test(f.creditCard), `${f.id} creditCard '${f.creditCard}'`).toBe(true);
  }
});

test('P8 - step 6: no real DemoBlaze catalog product name is reused', async ({ testData }) => {
  // A sample of the real storefront's catalog entries (real brand/product names).
  const realCatalogNames = [
    'Samsung galaxy s6', 'Nokia lumia 1520', 'Nexus 6', 'Samsung galaxy s7', 'Iphone 6 32gb',
    'Sony xperia z5', 'HTC One M9', 'Sony vaio i5', 'Sony vaio i7', 'MacBook air',
    'Dell i7 8gb', 'MacBook Pro', 'Apple monitor 24', 'ASUS Full HD',
  ];
  const lowered = new Set(realCatalogNames.map((n) => n.toLowerCase()));
  const brandTokens = ['samsung', 'nokia', 'nexus', 'iphone', 'apple', 'sony', 'htc', 'macbook', 'dell', 'asus'];
  for (const p of testData.products) {
    expect(lowered.has(p.title.toLowerCase()), `${p.id} reuses a real catalog name`).toBe(false);
    for (const b of brandTokens) {
      expect(p.title.toLowerCase().includes(b), `${p.id} '${p.title}' contains real brand token '${b}'`).toBe(false);
    }
    expect(p.synthetic).toBe(true);
  }
});

// ---------------------------------------------------------------- step 3 (boundary/AC coverage + tagging)
test('P9 - step 3: every case is tagged with coversAC and an expectedResult', async ({ testData }) => {
  for (const c of testData.cases) {
    expect(Array.isArray(c.coversAC) && c.coversAC.length > 0, `${c.id} coversAC`).toBe(true);
    expect(Array.isArray(c.coversCondition) && c.coversCondition.length > 0, `${c.id} coversCondition`).toBe(true);
    expect(Array.isArray(c.assumptionRefs), `${c.id} assumptionRefs`).toBe(true);
    expect(c.expectedResult && c.expectedResult.status, `${c.id} expectedResult.status`).toBeTruthy();
    expect(c.expectedResult.rule.length, `${c.id} expectedResult.rule`).toBeGreaterThan(10);
  }
});

test('P10 - step 3: AC1..AC9 are each covered by at least one case', async ({ testData }) => {
  const covered = new Set(testData.cases.flatMap((c) => c.coversAC));
  for (let i = 1; i <= 9; i++) expect(covered.has(`AC${i}`), `AC${i} uncovered`).toBe(true);
});

test('P11 - step 3: every test condition of 03-design.md is covered by at least one case', async ({ testData }) => {
  const designConditions = [
    'AC1-C1', 'AC1-C2', 'AC2-C1', 'AC2-C2', 'AC2-C3', 'AC2-C4', 'AC3-C1',
    'AC4-C1', 'AC4-C2', 'AC4-C3', 'AC5-C1', 'AC6-C1', 'AC6-C2',
    'AC7-C1', 'AC7-C2', 'AC7-C3', 'AC8-C1', 'AC8-C2', 'AC8-C3', 'AC8-C4', 'AC9-C1',
  ];
  const covered = new Set(testData.cases.flatMap((c) => c.coversCondition));
  for (const cond of designConditions) expect(covered.has(cond), `${cond} uncovered`).toBe(true);
});

test('P12 - every assumptionRef resolves to a declared _meta assumption', async ({ testData }) => {
  const declared = new Set(testData._meta.assumptions.map((a) => a.id));
  const used = new Set();
  for (const c of testData.cases) for (const r of c.assumptionRefs) { expect(declared.has(r), `${c.id} -> ${r}`).toBe(true); used.add(r); }
  for (const f of testData.orderForms) for (const r of (f.assumptionRefs || [])) { expect(declared.has(r), `${f.id} -> ${r}`).toBe(true); used.add(r); }
  // no dead assumption
  for (const a of declared) expect(used.has(a), `${a} declared but never referenced`).toBe(true);
});

// ---------------------------------------------------------------- step 5 ([open] discipline)
test('P13 - step 5: [open] cases genuinely list both interpretations and assert no outcome', async ({ testData }) => {
  const open = testData.cases.filter((c) => c.expectedResult.status === '[open]');
  expect(open.length, 'no [open] case at all').toBeGreaterThan(0);
  for (const c of open) {
    expect(c.expectedResult.rule).toMatch(/\(a\)/);
    expect(c.expectedResult.rule).toMatch(/\(b\)/);
    expect(c.expectedResult.rule.toLowerCase()).toMatch(/not resolved/);
  }
});

// ---------------------------------------------------------------- no dead fixture weight
test('P14 - no product, shopper, api response or order form is dead fixture weight', async ({ testData }) => {
  const raw = JSON.stringify(testData.cases) + JSON.stringify(testData.carts) + JSON.stringify(testData.cartItems);
  for (const name of ['products', 'shoppers', 'apiResponses', 'orderForms']) {
    for (const row of testData[name]) {
      const used = raw.includes(`"${row.id}"`);
      if (!used) console.log(`UNUSED: ${name}/${row.id}`);
      expect(used || !!row.note, `${name}/${row.id} unused and undocumented`).toBe(true);
    }
  }
});

// ---------------------------------------------------------------- exact literals from the testbook
test('P15 - the alert literals match the testbook byte-for-byte (period vs no period)', async ({ testData }) => {
  const loggedIn = testData.apiResponses.find((a) => a.id === 'API-004');
  const guest = testData.apiResponses.find((a) => a.id === 'API-005');
  expect(loggedIn.expectedAlert).toBe('Product added.');
  expect(guest.expectedAlert).toBe('Product added');
  expect(loggedIn.expectedAlert).not.toBe(guest.expectedAlert);
  const expired = testData.apiResponses.find((a) => a.id === 'API-001');
  expect(expired.expectedAlert).toBe('Your token has expired, please login again.');
});

test('P16 - AC7-C3 boundary is exactly one space character, computed not eyeballed', async ({ testData }) => {
  const f = testData.orderForms.find((x) => x.id === 'OF-004');
  expect(f.creditCard.length).toBe(1);
  expect(f.creditCard.charCodeAt(0)).toBe(32);
  expect(f.creditCard === '').toBe(false); // this is exactly why purchaseOrder() does not block it
  expect(f.creditCard.trim()).toBe('');    // ... and exactly why a .trim() would
});

test('P17 - every case that cites a scenarioId cites one that exists in the testbook', async ({ testData }) => {
  const fs = require('fs');
  const path = require('path');
  const feature = fs.readFileSync(
    path.join(__dirname, '..', '..', 'skill-eval-campaign-2026-07-29', 'US-EVAL-008-demoblaze', 'testbooks', 'cart-checkout.feature'),
    'utf8',
  );
  const tagged = testData.cases.filter((c) => c.scenarioId);
  expect(tagged.length).toBeGreaterThan(0);
  for (const c of tagged) expect(feature.includes(`@${c.scenarioId}`), `${c.id} -> ${c.scenarioId} not in feature`).toBe(true);
});
