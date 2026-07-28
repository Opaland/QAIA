// Real end-to-end smoke test: spawns the actual server process and talks real MCP protocol
// over stdio via the official client SDK, exactly as Cursor/Copilot would. Not run by
// `npm test` (node --test doesn't drive this well due to the child process lifecycle) --
// run manually: node test/smoke-e2e.mjs
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const serverPath = path.join(__dirname, '..', 'src', 'server.js');

const transport = new StdioClientTransport({ command: 'node', args: [serverPath] });
const client = new Client({ name: 'qaia-bridge-smoke-test', version: '0.1.0' });
await client.connect(transport);

const tools = await client.listTools();
console.log('tools:', tools.tools.map((t) => t.name).join(', '));
if (!tools.tools.find((t) => t.name === 'score_feature')) throw new Error('score_feature missing');

const listResult = await client.callTool({ name: 'list_skills', arguments: {} });
const skills = JSON.parse(listResult.content[0].text);
console.log('skills found via real MCP call:', skills.length);
if (skills.length < 29) throw new Error(`expected >= 29 skills over real MCP, got ${skills.length}`);

const scoreResult = await client.callTool({
  name: 'score_feature',
  arguments: {
    featureContent:
      'Feature: demo\n  @QAIA-DEMO-001 @ep @P1\n  Scenario: hollow\n    Given a thing\n    When it happens\n    Then it works\n',
  },
});
const score = JSON.parse(scoreResult.content[0].text);
console.log('score_feature over real MCP:', score.gate);
if (score.gate !== 'FAIL') throw new Error(`expected FAIL on hollow Then over real MCP, got ${score.gate}`);

await client.close();
console.log('SMOKE TEST PASSED — real MCP client/server round trip works end to end.');
