import 'dotenv/config';
import express from 'express';
import cors from 'cors';

import { authRouter } from './routes/auth.js';
import { errorHandler } from './middleware/errorHandler.js';

const app = express();

app.use(
  cors({
    origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : true,
    credentials: true,
  }),
);
app.use(express.json({ limit: '1mb' }));

app.get('/health', (req, res) => res.json({ ok: true }));

// DB connectivity check — hit this from a browser to verify PG is reachable.
app.get('/health/db', async (req, res) => {
  try {
    const { pool } = await import('./db/pool.js');
    const result = await pool.query('SELECT NOW() AS now');
    res.json({ ok: true, time: result.rows[0].now });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
});

app.use('/api/auth', authRouter);

// Global error handler — must be last middleware
app.use(errorHandler);

const port = Number(process.env.PORT || 3000);
app.listen(port, () => {
  // Avoid logging secrets
  console.log(`dlab-backend listening on :${port}`);
});
