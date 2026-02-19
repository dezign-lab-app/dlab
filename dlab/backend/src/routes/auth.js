import { Router } from 'express';
import { z } from 'zod';

import { verifyFirebaseToken } from '../middleware/verifyFirebaseToken.js';
import { upsertUserFromFirebase } from '../services/userSync.js';

export const authRouter = Router();

// POST /api/auth/sync-user
// Authorization: Bearer <Firebase ID Token>
// Body: { fullName?, phone?, avatarUrl?, role?, provider? }
authRouter.post('/sync-user', verifyFirebaseToken, async (req, res) => {
  const bodySchema = z
    .object({
      fullName: z.string().min(1).max(150).optional(),
      phone: z.string().min(1).max(20).optional(),
      avatarUrl: z.string().url().optional(),
      role: z.string().min(1).max(30).optional(),
      provider: z.string().min(1).max(50).optional(),
    })
    .strict();

  const parsed = bodySchema.safeParse(req.body ?? {});
  if (!parsed.success) {
    return res.status(400).json({ message: 'Invalid body', issues: parsed.error.issues });
  }

  const firebaseUser = req.firebaseUser;

  const user = await upsertUserFromFirebase({
    firebaseUser,
    profile: parsed.data,
  });

  return res.json({ success: true, user });
});
