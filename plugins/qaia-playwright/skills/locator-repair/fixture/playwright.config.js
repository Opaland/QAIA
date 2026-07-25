const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: '.',
  timeout: 10000,
  workers: 1,
  retries: 0,
  reporter: [['list'], ['junit', { outputFile: 'results.xml' }]],
  use: { baseURL: 'http://localhost:4602', screenshot: 'only-on-failure' },
  webServer: {
    command: 'node server.js',
    port: 4602,
    reuseExistingServer: false,
    timeout: 5000,
  },
});
