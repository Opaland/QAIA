// Page Object — "Dynamically Loaded Page Elements" (Examples 1 & 2, the-internet.herokuapp.com).
// Selectors only, no assertions (assertions live in tests) — automate skill rule (T2/POM-as-fixtures).
exports.DynamicLoadingPage = class DynamicLoadingPage {
  constructor(page) {
    this.page = page;
    // Both examples share the same fragment structure: #start > button, #loading (inserted on
    // click), #finish (Example 1: pre-existing, display:none; Example 2: does not exist until
    // the setTimeout callback inserts it into the DOM).
    this.startButton = page.locator('#start button');
    this.loadingIndicator = page.locator('#loading');
    // DELIBERATE BREAK (skill-coverage wave 2026-07-30, locator-repair exercise):
    // the real page exposes the reveal target as `<div id="finish">`; this locator points at a
    // testid that does not exist on the page at all. Expected failure mode:
    // locator-not-found / timeout on getByTestId.
    this.finish = page.getByTestId('finish-message');
  }

  async goto(exampleNumber) {
    await this.page.goto(`/dynamic_loading/${exampleNumber}`);
  }

  async clickStart() {
    await this.startButton.click();
  }
};
