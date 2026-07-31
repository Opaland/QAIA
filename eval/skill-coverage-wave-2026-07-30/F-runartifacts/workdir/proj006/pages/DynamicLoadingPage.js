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
    this.finish = page.locator('#finish');
  }

  async goto(exampleNumber) {
    await this.page.goto(`/dynamic_loading/${exampleNumber}`);
  }

  async clickStart() {
    await this.startButton.click();
  }
};
