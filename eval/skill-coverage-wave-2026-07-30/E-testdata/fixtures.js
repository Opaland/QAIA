// SKILL.md step 8 — the POM-as-fixtures injection pattern (D34), materialized in-session.
// The plugin ships no runtime code; this file is generated where the tests live.
const fs = require('fs');
const path = require('path');
const base = require('@playwright/test');

exports.test = base.test.extend({
  testData: async ({}, use) => {
    const raw = fs.readFileSync(path.join(__dirname, 'US-EVAL-008-dataset.json'), 'utf8');
    await use(JSON.parse(raw));
  },
});
exports.expect = base.expect;
