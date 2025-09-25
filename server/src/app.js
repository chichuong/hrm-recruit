const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();
const { errorHandler } = require('./core/error');

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(morgan('dev'));

// Health check
app.get('/health', (req, res) => {
  res.json({ ok: true, service: 'hrm-recruit-api', ts: new Date().toISOString() });
});

// 404 fallback
app.use((req, res, next) => {
  res.status(404).json({ ok: false, message: 'Not Found' });
});

// Error handler
app.use(errorHandler);

module.exports = app;
