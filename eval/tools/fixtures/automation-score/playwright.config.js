// Minimal config for the automation_score.py mutation-track fixture.
// No web server and no network: the tests build their own DOM with page.setContent(),
// so the proof is fully offline and deterministic.
module.exports = {
  testDir: './tests',
  reporter: 'line',
  retries: 0,
  use: { headless: true },
};
