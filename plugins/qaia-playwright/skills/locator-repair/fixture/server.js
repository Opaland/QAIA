// Minimal static file server for the locator-repair fixture -- no framework,
// mirrors the pattern used by ../../flaky-detect/fixture/server.js.
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 4602;
const ROOT = __dirname;
const MIME = { '.html': 'text/html', '.js': 'text/javascript' };

http
  .createServer((req, res) => {
    const url = req.url === '/' ? '/app.html' : req.url;
    const filePath = path.join(ROOT, url);
    fs.readFile(filePath, (err, data) => {
      if (err) {
        res.writeHead(404);
        res.end('not found');
        return;
      }
      const ext = path.extname(filePath);
      res.writeHead(200, { 'Content-Type': MIME[ext] || 'text/plain' });
      res.end(data);
    });
  })
  .listen(PORT, () => console.log(`locator-repair fixture server on ${PORT}`));
