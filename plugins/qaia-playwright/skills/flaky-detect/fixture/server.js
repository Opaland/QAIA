// Minimal fixture SUT: shared in-memory state, no isolation between requests.
// Deliberately mirrors the real bug class found in examples/medibook (Sprint 5
// flake hunt) and examples/expense-demo (D68): a server holding global mutable
// state, hit by concurrent test workers with no serialization. This is what
// produces genuine flakiness (verdict varies run to run, same code) rather
// than a fabricated random()-driven failure.
const http = require('http');

let items = [];

const server = http.createServer((req, res) => {
  let body = '';
  req.on('data', (c) => { body += c; });
  req.on('end', () => {
    if (req.method === 'POST' && req.url === '/reset') {
      items = [];
      res.writeHead(200);
      res.end('ok');
    } else if (req.method === 'POST' && req.url === '/items') {
      // A tiny bit of async work widens the interleaving window between
      // concurrent requests hitting the same shared `items` array.
      const delay = Math.random() * 20;
      setTimeout(() => {
        items.push(Date.now());
        res.writeHead(200);
        res.end('ok');
      }, delay);
    } else if (req.method === 'GET' && req.url === '/count') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ count: items.length }));
    } else {
      res.writeHead(404);
      res.end();
    }
  });
});

const PORT = process.env.PORT || 4601;
server.listen(PORT, () => console.log(`flaky-fixture server on ${PORT}`));
