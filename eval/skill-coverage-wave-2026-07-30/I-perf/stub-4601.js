// Trivial self-hosted stub SUT on :4601 that does NOT expose /api/login or /api/reports.
// Used to test SKILL.md line 22's portability claim ("BASE_URL/LATENCY_BUDGET_MS/VUS/DURATION
// are the only parts a generated test needs to change to point at a different self-hosted target").
const http = require('http');
http
  .createServer((req, res) => {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'not found', path: req.url }));
  })
  .listen(4601, () => console.log('stub SUT on http://localhost:4601'));
