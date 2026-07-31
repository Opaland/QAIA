// Page Object — post-login product catalog. Selectors only, no assertions.
exports.InventoryPage = class InventoryPage {
  constructor(page) {
    this.page = page;
    this.container = page.getByTestId('inventory-container');
  }
};
