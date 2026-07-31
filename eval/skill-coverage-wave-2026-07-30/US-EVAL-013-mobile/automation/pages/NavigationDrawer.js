// Page Object — the phone navigation drawer (the subject of US-EVAL-013). Selectors + actions
// only, NO assertions (automate SKILL.md line 19).
//
// TESTABILITY GAP TG-1 (automate SKILL.md step 2 — reported, NOT routed around):
// the drawer container itself carries no `role`, no `data-test`, no `id` — measured, not assumed
// (`probe-testids.js` → drawerContainer: { dataTest: null, role: null, hasIdOrTestId: false }).
// It is a third-party `react-burger-menu` wrapper identified only by the CSS class `.bm-menu-wrap`,
// and `aria-hidden` — the state AC4 asserts on — lives on that same wrapper. There is therefore no
// role/testid-first way to reach the element the requirement is about. The class locator below is a
// DECLARED deviation from the "role / data-testid only" rule, documented here and in
// traceability.md, not a silent workaround; it is still a stable semantic class, not positional
// XPath (which the rules forbid outright). Fix on the SUT side: `data-test="nav-drawer"` +
// `role="dialog"` on `.bm-menu-wrap`.
exports.NavigationDrawer = class NavigationDrawer {
  constructor(page) {
    this.page = page;
    // The visible controls DO expose accessible names — measured: the burger button's text is
    // "Open Menu" and the close button's is "Close Menu" (`probe-testability.js`), so these two
    // are role-first as the rules require.
    this.burger = page.getByRole('button', { name: 'Open Menu' });
    this.closeButton = page.getByRole('button', { name: 'Close Menu' });
    this.wrapper = page.locator('.bm-menu-wrap'); // TG-1
    this.itemList = page.locator('.bm-menu-wrap .bm-item-list'); // TG-1
    this.logoutLink = page.getByTestId('logout-sidebar-link');
    this.allItemsLink = page.getByTestId('inventory-sidebar-link');
  }

  // SYNCHRONISATION FINDING F-1 (found by the real run, not by inspection — see traceability.md):
  // `aria-hidden` on `.bm-menu-wrap` flips to "false" the instant the burger is tapped, but the
  // drawer is still fully OFF-SCREEN at that moment (measured: `drawerBox.x = -412` on a 412 px
  // Pixel 7 viewport, `probe-004-diagnosis.js`). Waiting on the attribute alone therefore does NOT
  // mean "the drawer is open" — it means "the drawer has been asked to open". The first generated
  // version of these two methods did exactly that and made @QAIA-US-EVAL-013-004 fail on BOTH
  // engines. The wait below is on rendered GEOMETRY, which is the state the AC is actually about.
  // No fixed sleep is used: a `waitForTimeout` here would be the flakiness that
  // qaia-playwright:flaky-detect exists to surface.
  async open() {
    await this.burger.click();
    await this.page.waitForFunction(() => {
      const w = document.querySelector('.bm-menu-wrap');
      if (!w || w.getAttribute('aria-hidden') !== 'false') return false;
      const r = w.getBoundingClientRect();
      return r.width > 0 && r.left >= 0; // fully slid in
    });
  }

  async close() {
    await this.closeButton.click();
    await this.page.waitForFunction(() => {
      const w = document.querySelector('.bm-menu-wrap');
      if (!w || w.getAttribute('aria-hidden') !== 'true') return false;
      const r = w.getBoundingClientRect();
      return r.right <= 0; // fully slid out
    });
  }

  async ariaHidden() {
    return this.wrapper.getAttribute('aria-hidden');
  }

  /** Rendered CSS width of the drawer, in px (AC1/AC2 boundary measurements). */
  async renderedWidth() {
    const box = await this.wrapper.boundingBox();
    return Math.round(box.width);
  }

  /** Rendered size of the burger control, for the WCAG 2.2 SC 2.5.8 target-size oracle (AC7). */
  async burgerSize() {
    const box = await this.burger.boundingBox();
    return { width: Math.round(box.width), height: Math.round(box.height) };
  }

  async logout() {
    await this.logoutLink.click();
  }

  /** Every control anywhere on the page whose accessible text mentions logout / sign out (AC4). */
  async signOutControlsOnPage() {
    return this.page.evaluate(() =>
      [...document.querySelectorAll('a,button,input')]
        .filter((e) => /log\s?out|sign\s?out/i.test(`${e.textContent || ''} ${e.value || ''}`))
        .map((e) => ({ tag: e.tagName, insideDrawer: !!e.closest('.bm-menu-wrap') })));
  }
};
