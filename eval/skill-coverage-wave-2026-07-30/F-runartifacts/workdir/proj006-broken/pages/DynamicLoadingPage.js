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
    // REPAIR APPLIED BY THE OPERATOR (not by the skill — locator-repair SKILL.md lines 76-77
    // forbid the skill from writing this file or re-running the test).
    // No data-testid exists anywhere on the-internet's dynamic_loading pages (verified: 0 hits
    // in the captured DOM), so the reveal target is pinned by its accessible role+name instead.
    this.finish = page.getByRole('heading', { name: 'Hello World!' });
  }

  async goto(exampleNumber) {
    await this.page.goto(`/dynamic_loading/${exampleNumber}`);
  }

  async clickStart() {
    await this.startButton.click();
  }
};
