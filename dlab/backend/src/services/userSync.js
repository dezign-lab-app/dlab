import { pool } from '../db/pool.js';

// Columns matching schema.sql users table exactly:
//   id UUID, firebase_uid, email, name, phone, avatar,
//   auth_provider (enum: 'email'|'google'),
//   is_active, is_blocked, is_deleted, last_login_at, created_at, updated_at

const RETURNING_COLS = `
  id, firebase_uid, email, name, phone, avatar,
  auth_provider::text AS auth_provider,
  is_active, is_blocked, last_login_at, created_at, updated_at
`;

export async function upsertUserFromFirebase({ firebaseUser, profile }) {
  const firebaseUid = firebaseUser.uid;
  const email       = firebaseUser.email ?? null;

  if (!email) {
    throw new Error('Firebase token does not contain email');
  }

  // Normalise provider → valid auth_provider_enum value ('email' | 'google').
  const rawProvider  = profile.provider ?? firebaseUser.firebase?.sign_in_provider ?? 'email';
  const authProvider = rawProvider.includes('google') ? 'google' : 'email';

  const name   = profile.fullName ?? firebaseUser.name    ?? null;
  const avatar = profile.avatarUrl ?? firebaseUser.picture ?? null;
  const phone  = profile.phone ?? null;

  const client = await pool.connect();
  try {
    const sql = `
      INSERT INTO users (
        firebase_uid,
        email,
        name,
        phone,
        avatar,
        auth_provider,
        last_login_at,
        updated_at
      )
      VALUES ($1, $2, $3, $4, $5, $6::auth_provider_enum, NOW(), NOW())
      ON CONFLICT (firebase_uid)
      DO UPDATE SET
        email         = EXCLUDED.email,
        name          = COALESCE(EXCLUDED.name,   users.name),
        phone         = COALESCE(EXCLUDED.phone,  users.phone),
        avatar        = COALESCE(EXCLUDED.avatar, users.avatar),
        auth_provider = EXCLUDED.auth_provider,
        last_login_at = NOW(),
        updated_at    = NOW()
      RETURNING ${RETURNING_COLS};
    `;

    const values = [firebaseUid, email, name, phone, avatar, authProvider];
    const result = await client.query(sql, values);
    return result.rows[0];
  } finally {
    client.release();
  }
}

/**
 * Fetches a user row from PostgreSQL by Firebase UID.
 * Updates last_login_at as a side-effect.
 * Returns null if no user is found.
 */
export async function getUserByFirebaseUid(firebaseUid) {
  const client = await pool.connect();
  try {
    const result = await client.query(
      `UPDATE users
          SET last_login_at = NOW(), updated_at = NOW()
        WHERE firebase_uid = $1
        RETURNING ${RETURNING_COLS}`,
      [firebaseUid],
    );
    return result.rows[0] ?? null;
  } finally {
    client.release();
  }
}
