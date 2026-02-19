import { pool } from '../db/pool.js';

// Maps Firebase decoded token to your users table.
// Your table uses snake_case and includes optional columns for profile.
export async function upsertUserFromFirebase({ firebaseUser, profile }) {
  const firebaseUid = firebaseUser.uid;
  const email = firebaseUser.email ?? null;

  if (!email) {
    // Email can be absent for some providers; if you require it, reject.
    throw new Error('Firebase token does not contain email');
  }

  const fullName = profile.fullName ?? firebaseUser.name ?? null;
  const avatarUrl = profile.avatarUrl ?? firebaseUser.picture ?? null;
  const provider = profile.provider ?? firebaseUser.firebase?.sign_in_provider ?? null;

  // Optional app role selection. Keep default USER if not provided.
  const role = profile.role ?? null;

  // Email verification in Firebase token
  const isEmailVerified = Boolean(firebaseUser.email_verified);

  const client = await pool.connect();
  try {
    const sql = `
      INSERT INTO users (
        firebase_uid,
        email,
        full_name,
        phone,
        avatar_url,
        role,
        provider,
        is_email_verified,
        last_login_at,
        updated_at
      )
      VALUES ($1,$2,$3,$4,$5,COALESCE($6, role, 'USER'),$7,$8,NOW(),NOW())
      ON CONFLICT (firebase_uid)
      DO UPDATE SET
        email = EXCLUDED.email,
        full_name = COALESCE(EXCLUDED.full_name, users.full_name),
        phone = COALESCE(EXCLUDED.phone, users.phone),
        avatar_url = COALESCE(EXCLUDED.avatar_url, users.avatar_url),
        provider = COALESCE(EXCLUDED.provider, users.provider),
        is_email_verified = EXCLUDED.is_email_verified,
        last_login_at = NOW(),
        updated_at = NOW()
      RETURNING
        id,
        firebase_uid,
        email,
        full_name,
        phone,
        avatar_url,
        role,
        provider,
        is_email_verified,
        is_active,
        is_blocked,
        last_login_at,
        created_at,
        updated_at;
    `;

    const values = [
      firebaseUid,
      email,
      fullName,
      profile.phone ?? null,
      avatarUrl,
      role,
      provider,
      isEmailVerified,
    ];

    const result = await client.query(sql, values);
    return result.rows[0];
  } finally {
    client.release();
  }
}
