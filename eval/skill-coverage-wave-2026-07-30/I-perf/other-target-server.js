// A second, deliberately different SELF-HOSTED target (port 4599) used to test SKILL.md's claim
// (line 22): "BASE_URL/LATENCY_BUDGET_MS/VUS/DURATION are the only parts a generated test needs
// to change to point at a different self-hosted target."
// This app is a plain read-only JSON service: no /api/login, no /api/reports.
const http = require('http');
http.createServer((req, res) => {
  if (req.url === '/api/items') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ items: [1, 2, 3] }));
  }
  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'not found' }));
}).listen(4599, () => console.log('other target on http://localhost:4599'));
