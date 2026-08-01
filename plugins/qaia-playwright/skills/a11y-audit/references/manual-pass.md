# The manual pass — what axe-core structurally cannot check

Automated tooling detects roughly a third of WCAG success criteria. The gap is not exotic: it is
keyboard operation, focus, and whether text alternatives actually say anything. These are the
failures that stop a disabled user, and they are invisible to a DOM scanner because they depend
on *sequence*, *rendered pixels*, or *meaning* — none of which axe evaluates.

Each check below states the protocol, the expected result, and the WCAG criterion it maps to.
Run every one on every screen under audit, and record a result for each — including "not
applicable", with the reason.

---

## M1 — Keyboard reachability (WCAG 2.1.1 Keyboard)

**Protocol.** From a fresh page load, press `Tab` repeatedly to the end of the page. Do not touch
the mouse. Note every interactive element (link, button, field, control, custom widget) that is
never reached.

**Expected.** Every interactive element is reachable and operable by keyboard alone. A control
that needs `Enter` or `Space` responds to it.

**Common real failure.** `<div onclick=...>` with no `tabindex` and no `role`: visible, clickable,
completely absent from the tab sequence. axe often passes it — the DOM is not malformed, it is
simply not focusable.

```js
// Automatable in Playwright: walk the tab order and record it.
const order = [];
for (let i = 0; i < 40; i++) {
  await page.keyboard.press('Tab');
  order.push(await page.evaluate(() => {
    const el = document.activeElement;
    return el ? `${el.tagName}${el.id ? '#' + el.id : ''}` : 'NONE';
  }));
}
```

---

## M2 — Keyboard trap (WCAG 2.1.2 No Keyboard Trap)

**Protocol.** Tab *into* every modal, date picker, embedded player and custom dropdown, then try
to leave using only `Tab` / `Shift+Tab` / `Escape`.

**Expected.** Focus can always leave. A modal returns focus to the element that opened it.

**Why it matters more than its rarity suggests.** A trap does not degrade the experience, it
ends the session: a keyboard-only user has no way out short of closing the tab.

---

## M3 — Focus order (WCAG 2.4.3 Focus Order)

**Protocol.** Compare the tab sequence recorded in M1 against the visual reading order.

**Expected.** They match. Focus does not jump between columns, does not visit the footer before
the form, does not enter hidden or off-screen content.

**Common real failure.** CSS reordering (`order`, `flex-direction: row-reverse`, absolute
positioning) changes what the eye sees but not what the tab key follows. The page looks fine and
navigates incoherently. Positive `tabindex` values do the same thing deliberately.

---

## M4 — Focus visibility (WCAG 2.4.7 Focus Visible)

**Protocol.** Repeat the M1 walk watching only for the focus indicator. Check it against the
background it actually sits on, in both light and dark theme if both ship.

**Expected.** The focused element is always visibly marked, with a contrast ratio ≥ 3:1 against
its adjacent background.

**Common real failure.** `outline: none` in a CSS reset, never replaced. This is the single most
frequent manual finding, it is invisible to axe (the CSS is valid), and it makes M1's "reachable"
useless: a user who cannot see where focus is cannot use a page they can technically traverse.

---

## M5 — Contrast in non-default states (WCAG 1.4.3 / 1.4.11)

**Protocol.** axe measures the default state. Measure the ones it never sees: `:hover`, `:focus`,
`:disabled`, `:visited`, placeholder text, error and success text, text over images or gradients.

**Expected.** ≥ 4.5:1 for body text, ≥ 3:1 for large text (≥ 18.66px bold or ≥ 24px) and for
meaningful UI components and graphics.

**Common real failure.** Disabled controls and placeholder text, both routinely styled at
`#ccc` on white — around 1.6:1. Also: an error message in light red that fails while the body
text that passed sits right above it.

---

## M6 — Text alternatives that mean something (WCAG 1.1.1 Non-text Content)

**Protocol.** Read every `alt`, `aria-label` and `aria-describedby` out of context and ask what
it conveys. axe checks the attribute *exists*; only a human checks it *says the right thing*.

**Expected.**
- Informative image → the information the image carries, not its filename.
- Decorative image → `alt=""` (empty, not missing), so screen readers skip it.
- Functional image (icon button) → what it **does**, not what it depicts. A printer icon that
  exports a PDF is "Export as PDF", not "printer".
- Complex image (chart, diagram) → short alt plus a long description nearby.

**Common real failure.** `alt="image"`, `alt="logo"`, `alt="IMG_4021.png"`, and every icon button
labelled by its shape. All pass axe. All convey nothing.

---

## M7 — Dynamic changes are announced (WCAG 4.1.3 Status Messages)

**Protocol.** Trigger every state change that produces no page navigation: form validation
errors, "saved" confirmations, search-result counts, loading states, toasts. Check each is in a
container with `role="status"`, `role="alert"` or an appropriate `aria-live`.

**Expected.** A screen-reader user learns the change happened without going to look for it.

**Common real failure.** Validation errors rendered next to fields with no live region: sighted
users see red immediately, screen-reader users get silence and a form that will not submit.

---

## Recording the results

The report carries one row per check per screen. `not applicable` is a valid result; a blank is
not, and neither is omitting the manual pass without saying so.

| Screen | Check | Result | Evidence |
|---|---|---|---|
| Login | M1 keyboard reachability | PASS | tab order recorded, 7 controls, all reached |
| Login | M4 focus visibility | **FAIL** | `outline:none` on `.btn`, no replacement, screenshot |
| Login | M6 alt relevance | N/A | no non-text content on this screen |

State who ran the manual pass and when. If it was run by an agent driving a browser rather than
a human — the normal case here — say that too: an agent can walk the tab order and measure
contrast reliably, and is weakest exactly where M6 lives, since judging whether alt text conveys
the right meaning is the one check that is genuinely about understanding the content.
