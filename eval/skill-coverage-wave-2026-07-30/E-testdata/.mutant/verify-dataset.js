// verify-dataset.js — independent verification harness for the dataset produced by
// plugins/qaia-testdata/skills/dataset-generate/SKILL.md against US-EVAL-008.
//
// Each check below names the SKILL.md step/guardrail it verifies. Pure node, zero deps,
// zero network — which is itself the "Portable" guardrail being exercised.
//
// Run:  node verify-dataset.js
// Exit: 0 if every check passes, 1 otherwise.

const fs = require('fs');
const path = require('path');

const HERE = __dirname;
const DATASET = path.join(HERE, 'US-EVAL-008-dataset.json');
const DESIGN = path.join(HERE, '..', '..', '..', 'skill-eval-campaign-2026-07-29', 'US-EVAL-008-demoblaze', 'state', '03-design.md');
const FEATURE = path.join(HERE, '..', '..', '..', 'skill-eval-campaign-2026-07-29', 'US-EVAL-008-demoblaze', 'testbooks', 'cart-checkout.feature');

const raw = fs.readFileSync(DATASET, 'utf8');
const d = JSON.parse(raw);

let failures = 0;
function check(id, promise, fn) {
  let ok, detail;
  try { const r = fn(); ok = r === true || r === undefined; detail = ok ? '' : String(r); }
  catch (e) { ok = false; detail = e.message; }
  if (!ok) failures++;
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${id}  [${promise}]${ok ? '' : '\n        -> ' + detail}`);
}

// ---------------------------------------------------------------- step 7: emission shape
check('P1', 'step 7: file is <US-ID>-dataset.json with _meta {US-ID, date, disclaimer, assumptions[]}', () => {
  if (path.basename(DATASET) !== `${d._meta.usId}-dataset.json`) return 'filename does not match _meta.usId';
  if (!d._meta.generatedAt) return 'no generation date';
  if (!/synthetic/i.test(d._meta.disclaimer || '')) return 'disclaimer missing or does not say synthetic';
  if (!Array.isArray(d._meta.assumptions) || d._meta.assumptions.length === 0) return 'no assumptions[]';
  for (const a of d._meta.assumptions) if (!/^ASM-\d+$/.test(a.id)) return `bad assumption id ${a.id}`;
  return true;
});

const entityArrays = ['shoppers', 'products', 'cartItems', 'carts', 'orderForms'];
check('P2', 'step 7: one array per entity', () => {
  for (const k of entityArrays) if (!Array.isArray(d[k]) || d[k].length === 0) return `${k} missing/empty`;
  return true;
});

check('P3', 'step 7: every case has id, description, entity refs, coversAC/coversCondition, assumptionRefs, expectedResult', () => {
  for (const c of d.cases) {
    for (const f of ['id', 'description', 'coversAC', 'coversCondition', 'assumptionRefs', 'expectedResult']) {
      if (c[f] === undefined) return `${c.id}: missing ${f}`;
    }
    if (!('shopperRef' in c) || !('cartRef' in c)) return `${c.id}: no entity refs`;
    if (!c.expectedResult.status) return `${c.id}: expectedResult has no status`;
  }
  return true;
});

// ------------------------------------------------- step 4: referential integrity + recompute
const shopperIds = new Set(d.shoppers.map((s) => s.id));
const productById = new Map(d.products.map((p) => [p.id, p]));
const cartById = new Map(d.carts.map((c) => [c.id, c]));
const itemById = new Map(d.cartItems.map((i) => [i.id, i]));
const formIds = new Set(d.orderForms.map((f) => f.id));

check('P4', 'step 4: every foreign key resolves', () => {
  for (const i of d.cartItems) {
    if (!cartById.has(i.cartId)) return `${i.id}: unknown cartId ${i.cartId}`;
    if (!productById.has(i.productId)) return `${i.id}: unknown productId ${i.productId}`;
  }
  for (const c of d.carts) {
    if (!shopperIds.has(c.shopperId)) return `${c.id}: unknown shopperId`;
    for (const it of c.itemIds) if (!itemById.has(it)) return `${c.id}: unknown item ${it}`;
  }
  for (const c of d.cases) {
    if (c.shopperRef && !shopperIds.has(c.shopperRef)) return `${c.id}: unknown shopperRef`;
    if (c.cartRef && !cartById.has(c.cartRef)) return `${c.id}: unknown cartRef`;
    if (c.orderFormRef && !formIds.has(c.orderFormRef)) return `${c.id}: unknown orderFormRef`;
    if (c.alternateOrderFormRef && !formIds.has(c.alternateOrderFormRef)) return `${c.id}: unknown alternateOrderFormRef`;
    for (const p of c.productRefs || []) if (!productById.has(p)) return `${c.id}: unknown productRef ${p}`;
    for (const it of (c.totalCheck ? c.totalCheck.itemRefs : [])) if (!itemById.has(it)) return `${c.id}: unknown itemRef ${it}`;
  }
  return true;
});

const priceOf = (itemId) => productById.get(itemById.get(itemId).productId).priceUsd;
const sum = (ids) => ids.reduce((a, id) => a + priceOf(id), 0);

check('P5a', 'step 4: each cart total is RECOMPUTED from its item prices, not eyeballed', () => {
  for (const c of d.carts) {
    const actual = sum(c.itemIds);
    if (Math.abs(actual - c.expectedTotalUsd) > 1e-9) return `${c.id}: stated ${c.expectedTotalUsd}, recomputed ${actual}`;
  }
  return true;
});

check('P5b', 'step 4: each case totalCheck/deleteCheck agrees with the raw rows', () => {
  for (const c of d.cases) {
    if (c.totalCheck) {
      const actual = sum(c.totalCheck.itemRefs);
      if (Math.abs(actual - c.totalCheck.expectedTotalUsd) > 1e-9) return `${c.id}: totalCheck stated ${c.totalCheck.expectedTotalUsd}, recomputed ${actual}`;
      const cart = cartById.get(c.cartRef);
      if (cart && c.totalCheck.itemRefs.length && JSON.stringify(cart.itemIds) !== JSON.stringify(c.totalCheck.itemRefs))
        return `${c.id}: totalCheck items diverge from cart ${cart.id} contents`;
    }
    if (c.deleteCheck) {
      const cart = cartById.get(c.cartRef);
      const remaining = cart.itemIds.filter((i) => i !== c.deleteCheck.deleteItemRef);
      if (JSON.stringify(remaining) !== JSON.stringify(c.deleteCheck.remainingItemRefs)) return `${c.id}: remainingItemRefs wrong`;
      const actual = sum(remaining);
      if (Math.abs(actual - c.deleteCheck.expectedTotalAfterUsd) > 1e-9) return `${c.id}: after-delete total stated ${c.deleteCheck.expectedTotalAfterUsd}, recomputed ${actual}`;
    }
  }
  return true;
});

// ------------------------------------------------------------------- step 6: no PII, ever
check('P6a', 'step 6: every person-like row has a <name> Sample-NN identity, @example.invalid email, synthetic:true', () => {
  for (const s of d.shoppers) {
    if (s.synthetic !== true) return `${s.id}: no synthetic flag`;
    if (!/ Sample-\d+$/.test(s.displayName)) return `${s.id}: name '${s.displayName}' does not match the "<first name> Sample-NN" pattern`;
    if (!/@example\.invalid$/.test(s.email)) return `${s.id}: email '${s.email}' is not on the RFC 2606 reserved TLD`;
  }
  return true;
});

check('P6b', 'step 6: no real-world product/company name anywhere in the file', () => {
  // Denylist = the real DemoBlaze catalogue vendors/models the target actually serves,
  // plus generic real brands a fixture might leak.
  const deny = ['samsung', 'nokia', 'sony', 'apple', 'iphone', 'macbook', 'dell', 'lenovo', 'asus',
    'htc', 'vaio', 'galaxy', 'lumia', 'xperia', 'nexus', 'visa', 'mastercard', 'amex'];
  const hay = raw.toLowerCase();
  const hits = deny.filter((w) => hay.includes(w));
  return hits.length ? `real brand tokens present: ${hits.join(', ')}` : true;
});

check('P6c', 'step 6 / guardrail: no value could be mistaken for a real payment card (no Luhn-valid 13-19 digit run)', () => {
  const luhn = (s) => {
    let sumv = 0, alt = false;
    for (let i = s.length - 1; i >= 0; i--) {
      let n = +s[i];
      if (alt) { n *= 2; if (n > 9) n -= 9; }
      sumv += n; alt = !alt;
    }
    return sumv % 10 === 0;
  };
  const runs = raw.replace(/[ -]/g, '').match(/\d{13,19}/g) || [];
  const bad = runs.filter(luhn);
  return bad.length ? `Luhn-valid digit runs found: ${bad.join(', ')}` : true;
});

check('P6d', 'step 6: no real-world-resolvable identifier (no http(s) URL, no non-reserved domain)', () => {
  const urls = raw.match(/https?:\/\/[^\s"]+/g) || [];
  if (urls.length) return `URLs present: ${urls.join(', ')}`;
  const emails = raw.match(/[\w.+-]+@[\w.-]+/g) || [];
  const bad = emails.filter((e) => !/@example\.invalid$/.test(e));
  return bad.length ? `non-reserved emails: ${bad.join(', ')}` : true;
});

// --------------------------------------------------------- step 5: assumptions / [open] forks
check('P7a', 'step 5: every assumptionRef resolves to a declared ASM-n', () => {
  const declared = new Set(d._meta.assumptions.map((a) => a.id));
  for (const c of d.cases) for (const r of c.assumptionRefs) if (!declared.has(r)) return `${c.id}: dangling ${r}`;
  return true;
});

check('P7b', 'step 5: every declared assumption is actually used by at least one case', () => {
  const used = new Set(d.cases.flatMap((c) => c.assumptionRefs));
  const unused = d._meta.assumptions.map((a) => a.id).filter((id) => !used.has(id));
  return unused.length ? `unused assumptions: ${unused.join(', ')}` : true;
});

check('P7c', 'step 5: every "[open]" case lists both interpretations instead of resolving the fork', () => {
  const open = d.cases.filter((c) => c.expectedResult.status === '[open]');
  if (open.length === 0) return 'no [open] case at all — suspicious for a US with a recorded open question (Q3)';
  for (const c of open) {
    if (!Array.isArray(c.expectedResult.interpretations) || c.expectedResult.interpretations.length < 2)
      return `${c.id}: [open] without >=2 interpretations`;
  }
  return true;
});

// ------------------------------------------------- step 3: coverage tagging back to AC/conditions
const designSrc = fs.readFileSync(DESIGN, 'utf8');
const featureSrc = fs.readFileSync(FEATURE, 'utf8');
const knownConditions = new Set(designSrc.match(/AC\d-C\d/g) || []);
const knownScenarioTags = new Set((featureSrc.match(/@QAIA-US-EVAL-008-\d+/g) || []).map((t) => t.slice(1)));

check('P8a', 'step 3: every coversCondition exists in 03-design.md', () => {
  for (const c of d.cases) if (!knownConditions.has(c.coversCondition)) return `${c.id}: condition ${c.coversCondition} not in 03-design.md`;
  return true;
});

check('P8b', 'step 3: every coversScenario exists as a tag in cart-checkout.feature', () => {
  for (const c of d.cases) if (c.coversScenario && !knownScenarioTags.has(c.coversScenario)) return `${c.id}: unknown scenario ${c.coversScenario}`;
  return true;
});

check('P8c', 'step 3: AC1..AC9 are each covered by at least one case', () => {
  const covered = new Set(d.cases.flatMap((c) => c.coversAC));
  const missing = [];
  for (let i = 1; i <= 9; i++) if (!covered.has(`AC${i}`)) missing.push(`AC${i}`);
  return missing.length ? `uncovered: ${missing.join(', ')}` : true;
});

check('P8d', 'step 3: every design condition of the US is covered by at least one case', () => {
  const covered = new Set(d.cases.map((c) => c.coversCondition));
  const missing = [...knownConditions].filter((k) => !covered.has(k));
  return missing.length ? `conditions with no data row: ${missing.join(', ')}` : true;
});

// -------------------------------------------------------- properties NOT promised by SKILL.md
check('X1', 'NOT promised by SKILL.md — id uniqueness across every entity array', () => {
  const dupes = [];
  for (const k of [...entityArrays, 'cases']) {
    const seen = new Set();
    for (const row of d[k]) { if (seen.has(row.id)) dupes.push(`${k}:${row.id}`); seen.add(row.id); }
  }
  return dupes.length ? `duplicate ids: ${dupes.join(', ')}` : true;
});

check('X2', 'NOT promised by SKILL.md — no dead fixture weight (every entity row referenced)', () => {
  const usedProducts = new Set(d.cartItems.map((i) => i.productId));
  const usedItems = new Set(d.carts.flatMap((c) => c.itemIds));
  const usedCarts = new Set(d.cases.map((c) => c.cartRef).filter(Boolean));
  const usedShoppers = new Set([...d.carts.map((c) => c.shopperId), ...d.cases.map((c) => c.shopperRef).filter(Boolean)]);
  const usedForms = new Set(d.cases.flatMap((c) => [c.orderFormRef, c.alternateOrderFormRef]).filter(Boolean));
  const dead = [
    ...d.products.filter((p) => !usedProducts.has(p.id)).map((p) => p.id),
    ...d.cartItems.filter((i) => !usedItems.has(i.id)).map((i) => i.id),
    ...d.carts.filter((c) => !usedCarts.has(c.id)).map((c) => c.id),
    ...d.shoppers.filter((s) => !usedShoppers.has(s.id)).map((s) => s.id),
    ...d.orderForms.filter((f) => !usedForms.has(f.id)).map((f) => f.id),
  ];
  return dead.length ? `unreferenced rows: ${dead.join(', ')}` : true;
});

check('X3', 'NOT promised by SKILL.md — cart owner cookie of each cart matches its shopper', () => {
  const cookieOf = new Map(d.shoppers.map((s) => [s.id, s.cartOwnerCookie]));
  for (const c of d.carts) {
    for (const it of c.itemIds) {
      if (itemById.get(it).ownerCookie !== cookieOf.get(c.shopperId)) return `${it}: ownerCookie != shopper ${c.shopperId}'s cookie`;
    }
  }
  return true;
});

console.log(`\n${failures === 0 ? 'ALL CHECKS PASSED' : failures + ' CHECK(S) FAILED'}  (dataset: ${path.basename(DATASET)}, ${d.cases.length} cases, ${d.shoppers.length + d.products.length + d.cartItems.length + d.carts.length + d.orderForms.length} entity rows)`);
process.exit(failures === 0 ? 0 : 1);
