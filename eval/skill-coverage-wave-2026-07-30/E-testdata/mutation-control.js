// mutation-control.js — negative control for verify-dataset.js.
// "ALL CHECKS PASSED" is worthless unless the checks can fail. This injects one violation of
// each promised property into a temp copy of the dataset and asserts the matching check fires.
//
// Run: node mutation-control.js

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const HERE = __dirname;
const SRC = path.join(HERE, 'US-EVAL-008-dataset.json');
const TMP = path.join(HERE, '.mutant');
const base = JSON.parse(fs.readFileSync(SRC, 'utf8'));

const mutations = [
  ['P1', 'strip the _meta disclaimer', (d) => { delete d._meta.disclaimer; }],
  ['P3', 'drop a case expectedResult', (d) => { delete d.cases[0].expectedResult; }],
  ['P4', 'point a cart item at a non-existent product', (d) => { d.cartItems[0].productId = 'PROD-999'; }],
  ['P5a', 'wrong cart total', (d) => { d.carts[1].expectedTotalUsd = 1149; }],
  ['P5b', 'wrong after-delete total', (d) => { d.cases.find((c) => c.deleteCheck).deleteCheck.expectedTotalAfterUsd = 1200; }],
  ['P6a', 'give a shopper a realistic name/email', (d) => { d.shoppers[0].displayName = 'Marie Dupont'; d.shoppers[0].email = 'marie.dupont@gmail.com'; }],
  ['P6b', 'leak a real product brand', (d) => { d.products[0].title = 'Samsung galaxy s6'; }],
  ['P6c', 'insert a Luhn-valid card number', (d) => { d.orderForms[0].creditCard = '4539578763621486'; }],
  ['P6d', 'insert a resolvable URL', (d) => { d.products[0].externalCatalogId = 'https://www.demoblaze.com/prod.html?idp_=1'; }],
  ['P7a', 'dangle an assumption ref', (d) => { d.cases[0].assumptionRefs = ['ASM-99']; }],
  ['P7b', 'declare an unused assumption', (d) => { d._meta.assumptions.push({ id: 'ASM-9', about: 'x', text: 'unused' }); }],
  ['P7c', 'silently resolve the open fork', (d) => { for (const c of d.cases) if (c.expectedResult.status === '[open]') c.expectedResult.status = 'pass'; }],
  ['P8a', 'cite a condition that does not exist in 03-design', (d) => { d.cases[0].coversCondition = 'AC9-C7'; }],
  ['P8b', 'cite a scenario tag that does not exist in the feature', (d) => { d.cases[2].coversScenario = 'QAIA-US-EVAL-008-099'; }],
  ['P8c', 'leave an AC uncovered', (d) => { d.cases = d.cases.filter((c) => !c.coversAC.includes('AC9')); }],
  ['X1', 'duplicate an id', (d) => { d.cases[1].id = d.cases[0].id; }],
  ['X2', 'add an unreferenced product row', (d) => { d.products.push({ id: 'PROD-099', title: 'Fixture Dead Sample-99', priceUsd: 1, externalCatalogId: null, synthetic: true }); }],
  ['X3', 'mismatch a cart item owner cookie', (d) => { d.cartItems[1].ownerCookie = 'SYNTHETIC-GUEST-COOKIE-0001'; }],
];

fs.mkdirSync(TMP, { recursive: true });
// the verifier resolves 03-design/.feature relative to its own dir, so run the copy from a
// sibling temp dir at the same depth
const verifierSrc = fs.readFileSync(path.join(HERE, 'verify-dataset.js'), 'utf8');
fs.writeFileSync(path.join(TMP, 'verify-dataset.js'), verifierSrc.replaceAll(
  "path.join(HERE, '..', '..', 'skill-eval-campaign-2026-07-29'",
  "path.join(HERE, '..', '..', '..', 'skill-eval-campaign-2026-07-29'"));

let bad = 0;
for (const [id, label, mutate] of mutations) {
  const d = JSON.parse(JSON.stringify(base));
  mutate(d);
  fs.writeFileSync(path.join(TMP, 'US-EVAL-008-dataset.json'), JSON.stringify(d, null, 2));
  let out;
  try { out = execFileSync(process.execPath, [path.join(TMP, 'verify-dataset.js')], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }); }
  catch (e) { out = e.stdout || ''; if (!out) { console.log(`ERROR    ${id} — verifier crashed: ${(e.stderr || '').split('\n')[2]}`); bad++; continue; } }
  const line = out.split('\n').find((l) => l.includes(`  ${id}  [`)) || '';
  const caught = line.startsWith('FAIL');
  if (!caught) bad++;
  console.log(`${caught ? 'CAUGHT   ' : 'MISSED!! '} ${id} — ${label}`);
}
fs.rmSync(TMP, { recursive: true, force: true });
console.log(`\n${bad === 0 ? 'NEGATIVE CONTROL OK' : bad + ' MUTATION(S) WENT UNDETECTED'} (${mutations.length} mutations)`);
process.exit(bad === 0 ? 0 : 1);
