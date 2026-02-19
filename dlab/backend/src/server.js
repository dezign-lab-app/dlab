import 'dotenv/config';
import express from 'express';
import cors from 'cors';

import { authRouter } from './routes/auth.js';

const app = express();

app.use(
  cors({
    origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : true,
    credentials: true,
  }),
);
app.use(express.json({ limit: '1mb' }));

app.get('/health', (req, res) => res.json({ ok: true }));
app.use('/api/auth', authRouter);

const port = Number(process.env.PORT || 3000);
app.listen(port, () => {
  // Avoid logging secrets
  console.log(`dlab-backend listening on :${port}`);
});
