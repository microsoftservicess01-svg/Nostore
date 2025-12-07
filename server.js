
// server.js - Static server for BraFit (no storage)
const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const app = express();
app.use(helmet());
app.use(morgan('tiny'));

const dist = path.join(__dirname, 'client', 'dist');
if (require('fs').existsSync(dist)) {
  app.use(express.static(dist));
  app.get('*', (req, res) => res.sendFile(path.join(dist, 'index.html')));
} else {
  app.get('/', (req, res) => res.send('Build the client (npm run build) and place dist in client/dist.'));
}

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log('BraFit static server listening on', PORT));
