// usability-heuristic-review exercise — LIVE exploration of the self-hosted MediBook SUT.
// Guardrail respected: "Self-hosted targets only (D35)" -> localhost:4401, started from
// examples/medibook/app/server.js. Nothing here is recalled: every string printed below is
// read from the running DOM.
const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const BASE = 'http://localhost:4401';
const OUT = __dirname;
const log = [];
function say(label, value) {
  const line = `\n### ${label}\n` + (typeof value === 'string' ? value : JSON.stringify(value, null, 2));
  console.log(line);
  log.push(line);
}

(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1280, height: 900 } });
  const consoleErrors = [];
  p.on('console', (m) => { if (m.type() === 'error') consoleErrors.push(m.text()); });

  // ---------- SCREEN 1: sign-in ----------
  await p.goto(BASE);
  await p.screenshot({ path: path.join(OUT, 'screens', '01-signin.png'), fullPage: true });
  say('S1 sign-in: visible text', (await p.locator('main').innerText()));
  say('S1 sign-in: interactive controls', await p.evaluate(() =>
    [...document.querySelectorAll('main input,main select,main button,main a')]
      .filter(e => e.offsetParent !== null)
      .map(e => ({ tag: e.tagName, id: e.id, type: e.type, text: (e.textContent||'').trim(), required: e.required, placeholder: e.placeholder, title: e.title }))));
  say('S1 sign-in: any help/docs affordance?', await p.evaluate(() => ({
    linksInDoc: [...document.querySelectorAll('a')].map(a => a.textContent.trim() + ' -> ' + a.getAttribute('href')),
    elementsMentioningHelp: [...document.querySelectorAll('*')].filter(e => e.children.length===0 && /help|support|forgot|contact|faq/i.test(e.textContent||'')).map(e => e.textContent.trim()),
  })));

  // H5 error prevention: submit empty
  await p.locator('#login-btn').click();
  await p.waitForTimeout(400);
  say('S1 H5: click "Sign in" with BOTH fields empty -> DOM state', await p.evaluate(() => ({
    messageEl: document.querySelector('#message') ? document.querySelector('#message').textContent : '(#message not in DOM on this screen)',
    anyVisibleMsg: [...document.querySelectorAll('.msg,[role=status],[role=alert]')].map(e => ({sel:e.className||e.getAttribute('role'), text:e.textContent.trim(), hidden:e.hidden})),
    appSectionHidden: document.querySelector('#app-section').hidden,
    emailValidity: document.querySelector('#email').validity.valid,
  })));
  await p.screenshot({ path: path.join(OUT, 'screens', '02-signin-empty-submit.png'), fullPage: true });

  // H9 error recovery: wrong password
  await p.locator('#email').fill('patient@demo');
  await p.locator('#password').fill('wrong-password');
  await p.locator('#login-btn').click();
  await p.waitForTimeout(600);
  say('S1 H9: wrong password -> message shown to the user (verbatim)', await p.evaluate(() => {
    const msgs = [...document.querySelectorAll('.msg,[role=status],[role=alert]')].map(e => e.textContent.trim()).filter(Boolean);
    return { messages: msgs, bodyTextAfter: document.querySelector('main').innerText };
  }));
  await p.screenshot({ path: path.join(OUT, 'screens', '03-signin-bad-password.png'), fullPage: true });

  // ---------- COGNITIVE WALKTHROUGH: book a slot (the @smoke journey) ----------
  await p.locator('#password').fill('demo1234');
  const t0 = Date.now();
  await p.locator('#login-btn').click();
  await p.locator('#app-section').waitFor({ state: 'visible' });
  say('CW step 2: time from click to slots screen (ms)', String(Date.now() - t0));
  await p.waitForTimeout(300);
  await p.screenshot({ path: path.join(OUT, 'screens', '04-slots.png'), fullPage: true });
  say('S2 slots: visible text', await p.locator('#app-section').innerText());
  say('S2 slots: raw HTML of the first slot row', await p.evaluate(() => {
    const s = document.querySelector('#slots > *');
    return s ? s.outerHTML : '(no slot rendered)';
  }));
  say('S2 slots: all slot rows (text + button label + disabled)', await p.evaluate(() =>
    [...document.querySelectorAll('#slots > *')].map(r => ({
      text: r.innerText.replace(/\n/g, ' | '),
      buttons: [...r.querySelectorAll('button')].map(btn => ({ label: btn.textContent.trim(), disabled: btn.disabled })),
    }))));
  say('S2 "My appointments" region content when empty', await p.evaluate(() => ({
    html: document.querySelector('#appointments').innerHTML,
    text: document.querySelector('#appointments').innerText,
  })));

  // H1 visibility of system status: is there a pending state during the async book call?
  const bookBtn = p.locator('#slots button:not([disabled])').first();
  const bookLabel = (await bookBtn.textContent()).trim();
  let slow = true;
  await p.route('**/api/**', async (route) => { if (slow) await new Promise(r => setTimeout(r, 1500)); await route.continue(); });
  await bookBtn.click();
  await p.waitForTimeout(500); // mid-flight
  say('CW step 3 / H1: DOM 500ms INTO the (artificially slowed) booking request', await p.evaluate(() => ({
    firstSlotHTML: document.querySelector('#slots > *')?.outerHTML,
    clickedButtonDisabled: document.querySelector('#slots button')?.disabled,
    clickedButtonLabel: document.querySelector('#slots button')?.textContent.trim(),
    messageRegion: document.querySelector('#message').textContent,
    anySpinnerOrBusy: [...document.querySelectorAll('[aria-busy],[class*=spin],[class*=load],progress')].length,
  })));
  await p.screenshot({ path: path.join(OUT, 'screens', '05-booking-inflight.png'), fullPage: true });
  slow = false;
  await p.waitForTimeout(2500);
  say('CW step 4 / H1: DOM AFTER the booking completed', await p.evaluate(() => ({
    messageRegion: document.querySelector('#message').textContent,
    appointments: document.querySelector('#appointments').innerText,
    appointmentsHTML: document.querySelector('#appointments').innerHTML,
  })));
  await p.screenshot({ path: path.join(OUT, 'screens', '06-booked.png'), fullPage: true });
  say('CW: the button label clicked to book was', bookLabel);

  // H3 user control and freedom: can the user undo/cancel the appointment?
  say('H3: controls available on the created appointment', await p.evaluate(() =>
    [...document.querySelectorAll('#appointments *')].filter(e => ['BUTTON','A'].includes(e.tagName))
      .map(e => ({ tag: e.tagName, text: e.textContent.trim(), href: e.getAttribute('href') }))));
  say('H3: every button present anywhere on the signed-in screen', await p.evaluate(() =>
    [...document.querySelectorAll('button')].map(e => e.textContent.trim())));

  // H5/H9: business-rule error path (minor without guardian) — real message text
  await p.locator('#logout-btn').click();
  await p.waitForTimeout(300);
  await p.locator('#email').fill('minor-noguardian@demo');
  await p.locator('#password').fill('demo1234');
  await p.locator('#login-btn').click();
  await p.locator('#app-section').waitFor({ state: 'visible' });
  await p.waitForTimeout(400);
  say('S2 (minor, no guardian): slot rows as rendered BEFORE clicking', await p.evaluate(() =>
    [...document.querySelectorAll('#slots > *')].map(r => ({
      text: r.innerText.replace(/\n/g, ' | '),
      buttons: [...r.querySelectorAll('button')].map(b => ({ label: b.textContent.trim(), disabled: b.disabled })),
    }))));
  await p.locator('#slots button:not([disabled])').first().click();
  await p.waitForTimeout(800);
  say('H9: business-rule rejection message (verbatim)', await p.evaluate(() => ({
    message: document.querySelector('#message').textContent,
    messageHTML: document.querySelector('#message').innerHTML,
  })));
  await p.screenshot({ path: path.join(OUT, 'screens', '07-minor-noguardian-error.png'), fullPage: true });

  // H2 match with the real world: raw jargon / codes leaking into the UI?
  say('H2: full visible page text on the signed-in screen (jargon scan)', await p.locator('body').innerText());
  say('Console errors observed during the whole session', consoleErrors);

  fs.writeFileSync(path.join(OUT, 'explore-output.md'), log.join('\n'), 'utf8');
  await b.close();
})();
