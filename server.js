// server.js - static server with graceful fallback
const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();

const dist = path.join(__dirname, 'client', 'dist');
if (fs.existsSync(dist)) {
  app.use(express.static(dist));
  app.get('*', (req, res) => res.sendFile(path.join(dist, 'index.html')));
} else {
  app.get('/', (req, res) => {
    res.send(`<html><head><title>BraFit</title></head><body><h1>BraFit</h1><p>No frontend build found. If you want the UI, add a <code>client/</code> folder and run the build in the Dockerfile.</p></body></html>`);
  });
}

const PORT = process.env.PORT || 3000;
app.listen(PORT, ()=>console.log('listening on', PORT));
