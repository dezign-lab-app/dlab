CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  firebase_uid VARCHAR(128) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,

  full_name VARCHAR(150),
  phone VARCHAR(20),
  avatar_url TEXT,

  role VARCHAR(30) DEFAULT 'USER',
  provider VARCHAR(50),

  is_email_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  is_blocked BOOLEAN DEFAULT FALSE,

  last_login_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP
);

CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);
