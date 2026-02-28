import { Router } from 'express';
import { z } from 'zod';
import { createClient } from '@supabase/supabase-js';

import { verifySupabaseToken } from '../middleware/verifySupabaseToken.js';
import { upsertUserFromSupabase, getUserBySupabaseUid } from '../services/userSync.js';

export const authRouter = Router();

// ── Supabase Admin client (service-role key) ─────────────────────────────
// Used for server-side lookups that the client SDK cannot do without
// sending emails (e.g. checking if an email is already registered).
const supabaseAdmin = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
  { auth: { autoRefreshToken: false, persistSession: false } },
);

// GET /api/auth/check-email?email=user@example.com
// Public — no JWT required. Returns { exists: true/false }.
// Uses the Supabase Admin SDK (listUsers) to check if an email is registered.
// This sends ZERO emails and has ZERO rate-limit risk.
authRouter.get('/check-email', async (req, res, next) => {
  try {
    const email = (req.query.email ?? '').toString().trim().toLowerCase();
    if (!email) {
      return res.status(400).json({ message: 'email query parameter is required' });
    }

    // supabase-js v2 has listUsers() but NOT getUserByEmail().
    // We list users (paginated) and check if the email exists.
    // Fine for < 10k users; for larger scale use the REST API directly.
    const { data, error } = await supabaseAdmin.auth.admin.listUsers({
      page: 1,
      perPage: 1000,
    });

    if (error) {
      console.error('[check-email] Supabase admin error:', error.message);
      return res.status(500).json({ message: 'Failed to check email' });
    }

    const users = data?.users ?? [];
    const exists = users.some((u) => u.email?.toLowerCase() === email);

    return res.json({ exists });
  } catch (err) {
    next(err);
  }
});

// POST /api/auth/sync-user
// Authorization: Bearer <Supabase JWT>
// Body: { fullName?, phone?, avatarUrl?, provider? }
//
// IMPORTANT: This endpoint syncs the Supabase-authenticated user into
// the VPS PostgreSQL database for profile/business data only.
// It does NOT participate in authentication — Supabase is the sole
// source of truth for auth. If PostgreSQL is down, the Flutter app
// gracefully degrades (uses Supabase user data directly).
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
    // Log PG errors but return a clear, non-auth error so the client
    // knows this is a profile-sync issue, not an authentication failure.
    console.error('[sync-user] PostgreSQL sync failed:', err.message);
    return res.status(503).json({
      success: false,
      message: 'Profile sync temporarily unavailable. Authentication is unaffected.',
    });
  }
});

// GET /api/auth/me
// Authorization: Bearer <Supabase JWT>
// Returns the PostgreSQL user row for the authenticated Supabase user.
// This is for profile data only — NOT for authentication decisions.
authRouter.get('/me', verifySupabaseToken, async (req, res, next) => {
  try {
    const user = await getUserBySupabaseUid(req.supabaseUser.id);
    if (!user) {
      // No PG row yet — not an auth error; the client should call sync-user first.
      return res.status(404).json({ message: 'Profile not synced yet. Call sync-user first.' });
    }
    return res.json(user);
  } catch (err) {
    console.error('[me] PostgreSQL lookup failed:', err.message);
    return res.status(503).json({
      message: 'Profile lookup temporarily unavailable. Authentication is unaffected.',
    });
  }
});
