# dlab-backend

Express + Firebase Admin + PostgreSQL.

## Setup

1) Copy `.env.example` to `.env` and fill values.
2) Put your Firebase Admin service account JSON at the path in `FIREBASE_SERVICE_ACCOUNT_PATH`.
3) Ensure the VPS Postgres has the `users` table you shared.

## Endpoints

- `GET /health`
- `POST /api/auth/sync-user` (Authorization: Bearer <Firebase ID Token>)

## Notes

- Do **not** commit `serviceAccount.json`.
- Use the Firebase ID token from Flutter in the `Authorization` header.
