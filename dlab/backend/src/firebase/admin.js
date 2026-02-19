import admin from 'firebase-admin';
import fs from 'node:fs';

let initialized = false;

export function getFirebaseAdmin() {
  if (initialized) return admin;

  const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  if (!serviceAccountPath) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT_PATH is not set');
  }

  const raw = fs.readFileSync(serviceAccountPath, 'utf8');
  const serviceAccount = JSON.parse(raw);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  initialized = true;
  return admin;
}
