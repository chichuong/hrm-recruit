const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();
const { errorHandler } = require('./core/error');

const authRoutes = require('./modules/auth');
const jobRoutes  = require('./modules/jobs');

const app = express();

app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(morgan('dev'));

const API_PREFIX = (process.env.API_PREFIX || '/api').replace(/\/+$/,'');

app.get(`${API_PREFIX}/health`, (req, res) => {
  res.json({ ok: true, service: 'hrm-recruit-api', ts: new Date().toISOString() });
});

app.use(`${API_PREFIX}/auth`, authRoutes);
app.use(`${API_PREFIX}/jobs`, jobRoutes);  

app.use((req, res) => res.status(404).json({ ok:false, message:'Not Found' }));

app.use(errorHandler);

module.exports = app;
