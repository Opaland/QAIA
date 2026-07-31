// Page Object — Swag Labs catalogue. Selectors + navigation only, NO assertions
// (automate SKILL.md line 19: "no assertions inside page objects").
exports.InventoryPage = class InventoryPage {
  constructor(page) {
    this.page = page;
    this.list = page.getByTestId('inventory-list');
    this.items = page.getByTestId('inventory-item');
    this.sortControl = page.getByTestId('product-sort-container');
    this.cartLink = page.getByTestId('shopping-cart-link');
    this.cartBadge = page.locator('.shopping_cart_badge'); // see traceability.md, testability gap TG-2
    this.firstAddToCart = page.getByTestId('add-to-cart-sauce-labs-backpack');
  }

  async goto() {
    await this.page.goto('/inventory.html');
  }

  async sortBy(value) {
    await this.sortControl.selectOption(value);
  }

  /** Bounding box of the first product card — used by the occlusion scenario (AC3). */
  async firstCardCentre() {
    const box = await this.items.first().boundingBox();
    return { x: Math.round(box.x + box.width / 2), y: Math.round(box.y + box.height / 2) };
  }

  /** Rendered CSS width of the sort control (AC6 boundary measurements). */
  async sortControlWidth() {
    const box = await this.sortControl.boundingBox();
    return Math.round(box.width);
  }

  /** Which element a tap at (x, y) would actually land on, and is it inside the drawer? */
  async topmostElementAt(x, y) {
    return this.page.evaluate(([px, py]) => {
      const el = document.elementFromPoint(px, py);
      return el
        ? { tag: el.tagName, className: String(el.className), insideDrawer: !!el.closest('.bm-menu-wrap') }
        : null;
    }, [x, y]);
  }
};
