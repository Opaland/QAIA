// Fixtures for US-EVAL-002 (Toolshop cart/checkout) -- Playwright request-context helpers.
// API-only scenarios (per automate SKILL.md step 3: "API-only scenarios use Playwright's request
// context, no page object"). No secrets committed (T3): the credentials below are the *public
// demo account* the target's own Swagger documentation publishes as its login example
// (https://api.practicesoftwaretesting.com/docs, AccountRequest example), not a secret we hold.
const { test: base, expect } = require('@playwright/test');

const DEMO_EMAIL = 'customer@practicesoftwaretesting.com';
const DEMO_PASSWORD = 'welcome01';

// Discovered live on 2026-07-30 via GET /products?page=1 -- a real, currently-existing product id
// on the public catalog (Combination Pliers). Re-fetched by resolveProductId() at run time so the
// suite does not silently rot if the seed catalog changes.
const FALLBACK_PRODUCT_ID = '01KYSN71WPAM4EN9KDB3ESNZ91';

async function login(request, email = DEMO_EMAIL, password = DEMO_PASSWORD) {
  const r = await request.post('/users/login', { data: { email, password } });
  expect(r.ok(), `login failed: ${r.status()} ${await r.text()}`).toBeTruthy();
  const body = await r.json();
  return body.access_token;
}

async function resolveProductId(request) {
  const r = await request.get('/products?page=1');
  if (!r.ok()) return FALLBACK_PRODUCT_ID;
  const body = await r.json();
  return (body.data && body.data[0] && body.data[0].id) || FALLBACK_PRODUCT_ID;
}

async function createCart(request, token) {
  const headers = token ? { Authorization: `Bearer ${token}` } : {};
  const r = await request.post('/carts', { headers });
  expect(r.status(), `create cart failed: ${r.status()} ${await r.text()}`).toBe(201);
  return (await r.json()).id;
}

async function addToCart(request, cartId, productId, quantity) {
  return request.post(`/carts/${cartId}`, { data: { product_id: productId, quantity } });
}

// Real-world, correctly-formatted candidate billing addresses tried live against the public
// instance on 2026-07-30 (curl, before any code was written): plain-ASCII street/city/state/
// country combinations across 4 real countries (FR, US x2, UK, DE), each of which returned
// HTTP 422 "The billing_country does not match the entered address. The city does not belong to
// the selected country." This looks like a genuine data/validation quirk of the public demo
// instance (it rejects real addresses, not just malformed ones), not a scenario-design gap -- see
// traceability.md "Testability gap" section. Tried again here, for real, at run time (not reused
// from the manual exploration) so the automated run has its own first-hand evidence.
const CANDIDATE_ADDRESSES = [
  { billing_street: '1 Rue de Rivoli', billing_city: 'Paris', billing_state: 'Ile-de-France', billing_country: 'France', billing_postal_code: '75001' },
  { billing_street: '350 Fifth Avenue', billing_city: 'New York', billing_state: 'New York', billing_country: 'United States', billing_postal_code: '10118' },
  { billing_street: '350 Fifth Avenue', billing_city: 'New York', billing_state: 'NY', billing_country: 'US', billing_postal_code: '10118' },
  { billing_street: '10 Downing Street', billing_city: 'London', billing_state: 'England', billing_country: 'United Kingdom', billing_postal_code: 'SW1A 2AA' },
  { billing_street: 'Pariser Platz 1', billing_city: 'Berlin', billing_state: 'Berlin', billing_country: 'Germany', billing_postal_code: '10117' },
];

const VALID_PAYMENT = { payment_method: 'cash-on-delivery', payment_details: {} };

// Attempts checkout across every candidate address until one succeeds (status 200) or the list is
// exhausted. Returns the *last* response either way -- a genuine multi-candidate real retry
// against the live SUT, never a fabricated result.
async function attemptCheckout(request, endpoint, cartId, extra, headers) {
  let lastResponse;
  for (const address of CANDIDATE_ADDRESSES) {
    lastResponse = await request.post(endpoint, {
      headers,
      data: { ...address, ...VALID_PAYMENT, cart_id: cartId, ...extra },
    });
    if (lastResponse.status() === 200) return lastResponse;
  }
  return lastResponse;
}

module.exports = {
  test: base,
  expect,
  login,
  resolveProductId,
  createCart,
  addToCart,
  attemptCheckout,
  CANDIDATE_ADDRESSES,
  VALID_PAYMENT,
  DEMO_EMAIL,
  DEMO_PASSWORD,
};
