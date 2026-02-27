import { Router } from 'express';
import { z } from 'zod';

import { verifySupabaseToken } from '../middleware/verifySupabaseToken.js';
import { upsertUserFromSupabase, getUserBySupabaseUid } from '../services/userSync.js';

export const authRouter = Router();

// POST /api/auth/sync-user
// Authorization: Bearer <Supabase JWT>
// Body: { fullName?, phone?, avatarUrl?, provider? }
authRouter.post('/sync-user', verifySupabaseToken, async (req, res, next) => {
  try {
    const bodySchema = z.object({
      fullName:  z.string().min(1).max(150).optional(),
      phone:     z.string().min(1).max(20).optional(),
      avatarUrl: z.string().url().optional(),
      provider:  z.string().min(1).max(50).optional(),
    });

    const parsed = bodySchema.safeParse(req.body ?? {});
    if (!parsed.success) {
      return res.status(400).json({ message: 'Invalid body', issues: parsed.error.issues });
    }

    const user = await upsertUserFromSupabase({
      supabaseUser: req.supabaseUser,
      profile: parsed.data,
    });

    return res.json({ success: true, user });
  } catch (err) {
    next(err);
  }
});

// GET /api/auth/me
// Authorization: Bearer <Supabase JWT>
// Returns the PostgreSQL user row for the authenticated Supabase user.
authRouter.get('/me', verifySupabaseToken, async (req, res, next) => {
  try {
    const user = await getUserBySupabaseUid(req.supabaseUser.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found. Please register first.' });
    }
    return res.json(user);
  } catch (err) {
    next(err);
  }
});
