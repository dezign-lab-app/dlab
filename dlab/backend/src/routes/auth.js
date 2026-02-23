import { Router } from 'express';
import { z } from 'zod';

import { verifyFirebaseToken } from '../middleware/verifyFirebaseToken.js';
import { upsertUserFromFirebase, getUserByFirebaseUid } from '../services/userSync.js';

export const authRouter = Router();

// POST /api/auth/sync-user
// Authorization: Bearer <Firebase ID Token>
// Body: { fullName?, phone?, avatarUrl?, role?, provider? }
authRouter.post('/sync-user', verifyFirebaseToken, async (req, res, next) => {
  try {
    const bodySchema = z.object({
      fullName:  z.string().min(1).max(150).optional(),
      phone:     z.string().min(1).max(20).optional(),
      avatarUrl: z.string().url().optional(),
      provider:  z.string().min(1).max(50).optional(),   // 'email' | 'google'
    });

    const parsed = bodySchema.safeParse(req.body ?? {});
    if (!parsed.success) {
      return res.status(400).json({ message: 'Invalid body', issues: parsed.error.issues });
    }

    const user = await upsertUserFromFirebase({
      firebaseUser: req.firebaseUser,
      profile: parsed.data,
    });

    return res.json({ success: true, user });
  } catch (err) {
    next(err);
  }
});

// GET /api/auth/me
// Authorization: Bearer <Firebase ID Token>
// Returns the PostgreSQL user row for the authenticated Firebase user.
authRouter.get('/me', verifyFirebaseToken, async (req, res, next) => {
  try {
    const user = await getUserByFirebaseUid(req.firebaseUser.uid);
    if (!user) {
      return res.status(404).json({ message: 'User not found. Please register first.' });
    }
    return res.json(user);
  } catch (err) {
    next(err);
  }
});
