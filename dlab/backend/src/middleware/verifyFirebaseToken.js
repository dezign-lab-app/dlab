import { getFirebaseAdmin } from '../firebase/admin.js';

/**
 * Verifies Firebase ID token from `Authorization: Bearer <token>`.
 * Attaches decoded token as `req.firebaseUser`.
 */
export async function verifyFirebaseToken(req, res, next) {
  const header = req.headers.authorization;
  const token = header?.startsWith('Bearer ') ? header.slice('Bearer '.length) : null;

  if (!token) return res.status(401).json({ message: 'Unauthorized' });

  try {
    const admin = getFirebaseAdmin();
    const decoded = await admin.auth().verifyIdToken(token);
    req.firebaseUser = decoded;
    return next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid token' });
  }
}
