const { defineConfig } = require('@playwright/test');

// No app under test, no browser needed - these specs only exercise the dataset fixture
// (fixtures.js -> testData), so a plain Node project is enough (D34's fixture-injection
// mechanism, not the page-object half of the pattern, which needs a real app).
module.exports = defineConfig({
  testDir: '.',
  timeout: 10000,
  fullyParallel: true,
  reporter: [['list'], ['json', { outputFile: 'results.json' }]],
  projects: [{ name: 'dataset', testMatch: /dataset\.spec\.js/ }],
});
