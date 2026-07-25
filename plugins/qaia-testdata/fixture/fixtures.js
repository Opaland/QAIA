// Worked example of the fixture-injection pattern documented in
// ../skills/dataset-generate/SKILL.md step 8. Mirrors the POM-as-fixtures convention (D34)
// already used by examples/medibook/tests/fixtures.js: instead of exposing a page object,
// this fixture exposes the parsed dataset so every test gets the same coherent data without
// re-reading/re-parsing the file itself.
const fs = require('fs');
const path = require('path');
const base = require('@playwright/test');

exports.test = base.test.extend({
  testData: async ({}, use) => {
    const raw = fs.readFileSync(path.join(__dirname, 'US-002-dosage-dataset.json'), 'utf8');
    await use(JSON.parse(raw));
  },
});
exports.expect = base.expect;
