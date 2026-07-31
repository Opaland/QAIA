// locator-repair skill, Input requirement: "A raw DOM capture (page.content(), or the trace's
// DOM snapshot) -- needed for getByTestId breaks" (SKILL.md line 36-37), because Playwright's
// auto-captured error-context.md ARIA snapshot does not carry data-testid attributes.
// Captures the post-reveal DOM of Example 2, i.e. the exact state the failing assertion targets.
const { chromium } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('https://the-internet.herokuapp.com/dynamic_loading/2');
  await page.click('#start button');
  await page.waitForSelector('#finish', { state: 'visible', timeout: 15000 });
  const html = await page.content();
  process.stdout.write(html);
  await browser.close();
})();
