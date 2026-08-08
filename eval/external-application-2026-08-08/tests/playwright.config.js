// Suite API pure : aucun navigateur, un seul projet. `SUT_URL` designe la version testee, ce qui
// permet de passer la MEME suite sur la version buggee et sur la version corrigee sans la toucher.
const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: '.',
  fullyParallel: false, // certains tests ecrivent dans la base ; l'ordre ne doit pas creer de course
  workers: 1,
  retries: 0, // un resultat qui a besoin d'un reessai n'est pas un resultat
  reporter: [['list'], ['json', { outputFile: 'results.json' }]],
  use: { trace: 'off', screenshot: 'off' },
  projects: [{ name: 'api' }],
});
