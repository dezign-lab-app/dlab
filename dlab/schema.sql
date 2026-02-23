-- ============================================================
-- DLabs PostgreSQL Schema
-- Auth: Firebase (email/password + Google)
-- Admin: Super Admin Panel (Next.js)
-- ============================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- for fast text search

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE auth_provider_enum      AS ENUM ('email', 'google');
CREATE TYPE order_status_enum       AS ENUM ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled', 'returned');
CREATE TYPE payment_status_enum     AS ENUM ('pending', 'paid', 'failed', 'refunded', 'partially_refunded');
CREATE TYPE payment_method_enum     AS ENUM ('card', 'upi', 'netbanking', 'wallet', 'cod', 'manual');
CREATE TYPE refund_status_enum      AS ENUM ('pending', 'processing', 'completed', 'failed');
CREATE TYPE product_status_enum     AS ENUM ('active', 'inactive', 'out_of_stock', 'archived');
CREATE TYPE discount_type_enum      AS ENUM ('percentage', 'flat');
CREATE TYPE review_status_enum      AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE notification_type_enum  AS ENUM ('push', 'email', 'sms');
CREATE TYPE campaign_status_enum    AS ENUM ('draft', 'scheduled', 'sent', 'cancelled');
CREATE TYPE banner_position_enum    AS ENUM ('homepage_hero', 'homepage_promo', 'category_top', 'checkout');
CREATE TYPE page_slug_enum          AS ENUM ('about_us', 'privacy_policy', 'terms_and_conditions');

-- ============================================================
-- 1. USERS  (Firebase Auth → PostgreSQL)
-- ============================================================

CREATE TABLE users (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    firebase_uid        VARCHAR(128)    UNIQUE NOT NULL,
    email               VARCHAR(255)    UNIQUE NOT NULL,
    name                VARCHAR(255),
    phone               VARCHAR(20),
    avatar              TEXT,
    auth_provider       auth_provider_enum  NOT NULL DEFAULT 'email',

    -- status
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    is_blocked          BOOLEAN         NOT NULL DEFAULT FALSE,
    is_deleted          BOOLEAN         NOT NULL DEFAULT FALSE,   -- soft delete
    blocked_reason      TEXT,
    deleted_at          TIMESTAMPTZ,

    -- timestamps
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    last_login_at       TIMESTAMPTZ,
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_firebase_uid  ON users(firebase_uid);
CREATE INDEX idx_users_email         ON users(email);
CREATE INDEX idx_users_phone         ON users(phone);
CREATE INDEX idx_users_is_blocked    ON users(is_blocked);
CREATE INDEX idx_users_is_deleted    ON users(is_deleted);
CREATE INDEX idx_users_created_at    ON users(created_at);

-- ============================================================
-- 2. USER LOGIN LOGS
-- ============================================================

CREATE TABLE user_login_logs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ip_address      VARCHAR(45),
    user_agent      TEXT,
    device_type     VARCHAR(50),
    auth_provider   auth_provider_enum,
    logged_in_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_login_logs_user_id     ON user_login_logs(user_id);
CREATE INDEX idx_login_logs_logged_in   ON user_login_logs(logged_in_at);

-- ============================================================
-- 3. USER ADDRESSES
-- ============================================================

CREATE TABLE user_addresses (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    label           VARCHAR(50),         -- e.g. Home, Work
    full_name       VARCHAR(255),
    phone           VARCHAR(20),
    line1           TEXT            NOT NULL,
    line2           TEXT,
    city            VARCHAR(100),
    state           VARCHAR(100),
    pincode         VARCHAR(20),
    country         VARCHAR(100)    NOT NULL DEFAULT 'India',
    is_default      BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_addresses_user_id ON user_addresses(user_id);

-- ============================================================
-- 4. SUPER ADMIN
-- ============================================================

CREATE TABLE super_admins (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email           VARCHAR(255)    UNIQUE NOT NULL,
    password_hash   TEXT            NOT NULL,
    name            VARCHAR(255),
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    last_login_at   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- Admin session / JWT refresh tokens
CREATE TABLE admin_sessions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id        UUID            NOT NULL REFERENCES super_admins(id) ON DELETE CASCADE,
    refresh_token   TEXT            UNIQUE NOT NULL,
    ip_address      VARCHAR(45),
    user_agent      TEXT,
    expires_at      TIMESTAMPTZ     NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_admin_sessions_admin_id ON admin_sessions(admin_id);

-- ============================================================
-- 5. CATEGORIES
-- ============================================================

CREATE TABLE categories (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id       UUID            REFERENCES categories(id) ON DELETE SET NULL,
    name            VARCHAR(255)    NOT NULL,
    slug            VARCHAR(255)    UNIQUE NOT NULL,
    description     TEXT,
    image_url       TEXT,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    sort_order      INTEGER         NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_categories_parent_id  ON categories(parent_id);
CREATE INDEX idx_categories_slug       ON categories(slug);
CREATE INDEX idx_categories_is_active  ON categories(is_active);

-- ============================================================
-- 6. PRODUCTS
-- ============================================================

CREATE TABLE products (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id         UUID            REFERENCES categories(id) ON DELETE SET NULL,
    name                VARCHAR(255)    NOT NULL,
    slug                VARCHAR(255)    UNIQUE NOT NULL,
    description         TEXT,
    sku                 VARCHAR(100)    UNIQUE,

    -- pricing
    base_price          NUMERIC(12,2)   NOT NULL,
    discount_price      NUMERIC(12,2),
    tax_percentage      NUMERIC(5,2)    NOT NULL DEFAULT 0,

    -- inventory
    stock_quantity      INTEGER         NOT NULL DEFAULT 0,
    low_stock_threshold INTEGER         NOT NULL DEFAULT 5,

    -- status
    status              product_status_enum NOT NULL DEFAULT 'active',

    -- SEO
    meta_title          VARCHAR(255),
    meta_description    TEXT,

    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_products_category_id  ON products(category_id);
CREATE INDEX idx_products_slug         ON products(slug);
CREATE INDEX idx_products_sku          ON products(sku);
CREATE INDEX idx_products_status       ON products(status);
CREATE INDEX idx_products_name_trgm    ON products USING GIN(name gin_trgm_ops);

-- Product images
CREATE TABLE product_images (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id      UUID            NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url       TEXT            NOT NULL,
    alt_text        VARCHAR(255),
    is_primary      BOOLEAN         NOT NULL DEFAULT FALSE,
    sort_order      INTEGER         NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_product_images_product_id ON product_images(product_id);

-- ============================================================
-- 7. CART
-- ============================================================

CREATE TABLE carts (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID            UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TABLE cart_items (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_id         UUID            NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id      UUID            NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity        INTEGER         NOT NULL DEFAULT 1 CHECK (quantity > 0),
    added_at        TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    UNIQUE(cart_id, product_id)
);

CREATE INDEX idx_cart_items_cart_id ON cart_items(cart_id);

-- ============================================================
-- 8. COUPONS & DISCOUNTS
-- ============================================================

CREATE TABLE coupons (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code                VARCHAR(50)     UNIQUE NOT NULL,
    description         TEXT,
    discount_type       discount_type_enum  NOT NULL,
    discount_value      NUMERIC(10,2)   NOT NULL,
    min_cart_value      NUMERIC(10,2)   NOT NULL DEFAULT 0,
    max_discount_cap    NUMERIC(10,2),               -- for % coupons
    usage_limit         INTEGER,                     -- NULL = unlimited
    used_count          INTEGER         NOT NULL DEFAULT 0,
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    auto_apply          BOOLEAN         NOT NULL DEFAULT FALSE,
    valid_from          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    valid_until         TIMESTAMPTZ,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_coupons_code      ON coupons(code);
CREATE INDEX idx_coupons_is_active ON coupons(is_active);

-- Category-specific coupons
CREATE TABLE coupon_categories (
    coupon_id       UUID    NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    category_id     UUID    NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (coupon_id, category_id)
);

-- Per-user coupon usage log
CREATE TABLE coupon_usage (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_id   UUID    NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    user_id     UUID    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_id    UUID,                           -- filled after order placed
    used_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_coupon_usage_coupon_id ON coupon_usage(coupon_id);
CREATE INDEX idx_coupon_usage_user_id   ON coupon_usage(user_id);

-- ============================================================
-- 9. ORDERS
-- ============================================================

CREATE TABLE orders (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID            NOT NULL REFERENCES users(id),
    order_number        VARCHAR(30)     UNIQUE NOT NULL,   -- human-readable e.g. ORD-2024-00001
    status              order_status_enum   NOT NULL DEFAULT 'pending',

    -- snapshot of address at time of order
    shipping_address    JSONB           NOT NULL,

    -- pricing
    subtotal            NUMERIC(12,2)   NOT NULL,
    discount_amount     NUMERIC(12,2)   NOT NULL DEFAULT 0,
    tax_amount          NUMERIC(12,2)   NOT NULL DEFAULT 0,
    shipping_charge     NUMERIC(12,2)   NOT NULL DEFAULT 0,
    total_amount        NUMERIC(12,2)   NOT NULL,

    -- coupon
    coupon_id           UUID            REFERENCES coupons(id),
    coupon_code         VARCHAR(50),

    -- admin
    admin_notes         TEXT,

    -- timestamps
    placed_at           TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    confirmed_at        TIMESTAMPTZ,
    shipped_at          TIMESTAMPTZ,
    delivered_at        TIMESTAMPTZ,
    cancelled_at        TIMESTAMPTZ,
    returned_at         TIMESTAMPTZ,
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_user_id     ON orders(user_id);
CREATE INDEX idx_orders_status      ON orders(status);
CREATE INDEX idx_orders_placed_at   ON orders(placed_at);
CREATE INDEX idx_orders_number      ON orders(order_number);

-- Order line items (snapshot of product at purchase time)
CREATE TABLE order_items (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id        UUID            NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id      UUID            REFERENCES products(id) ON DELETE SET NULL,
    product_name    VARCHAR(255)    NOT NULL,    -- snapshot
    sku             VARCHAR(100),
    quantity        INTEGER         NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(12,2)   NOT NULL,
    tax_percentage  NUMERIC(5,2)    NOT NULL DEFAULT 0,
    total_price     NUMERIC(12,2)   NOT NULL,
    image_url       TEXT
);

CREATE INDEX idx_order_items_order_id   ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Order status change history
CREATE TABLE order_status_logs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id        UUID            NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    old_status      order_status_enum,
    new_status      order_status_enum   NOT NULL,
    changed_by      VARCHAR(50),        -- 'admin' | 'system' | 'user'
    note            TEXT,
    changed_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_order_status_logs_order_id ON order_status_logs(order_id);

-- ============================================================
-- 10. PAYMENTS
-- ============================================================

CREATE TABLE payments (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id            UUID            NOT NULL REFERENCES orders(id),
    user_id             UUID            NOT NULL REFERENCES users(id),
    payment_method      payment_method_enum NOT NULL,
    payment_status      payment_status_enum NOT NULL DEFAULT 'pending',
    amount              NUMERIC(12,2)   NOT NULL,
    currency            VARCHAR(10)     NOT NULL DEFAULT 'INR',

    -- gateway info
    gateway_name        VARCHAR(50),        -- razorpay | stripe | paypal etc
    gateway_order_id    VARCHAR(255),
    gateway_payment_id  VARCHAR(255),
    gateway_signature   TEXT,
    gateway_response    JSONB,              -- full raw response

    failure_reason      TEXT,
    paid_at             TIMESTAMPTZ,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_order_id          ON payments(order_id);
CREATE INDEX idx_payments_user_id           ON payments(user_id);
CREATE INDEX idx_payments_status            ON payments(payment_status);
CREATE INDEX idx_payments_gateway_payment   ON payments(gateway_payment_id);

-- Refunds
CREATE TABLE refunds (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id          UUID            NOT NULL REFERENCES payments(id),
    order_id            UUID            NOT NULL REFERENCES orders(id),
    amount              NUMERIC(12,2)   NOT NULL,
    reason              TEXT,
    refund_status       refund_status_enum  NOT NULL DEFAULT 'pending',
    gateway_refund_id   VARCHAR(255),
    initiated_by        VARCHAR(50),        -- 'admin' | 'system'
    initiated_at        TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    completed_at        TIMESTAMPTZ,
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refunds_payment_id ON refunds(payment_id);
CREATE INDEX idx_refunds_order_id   ON refunds(order_id);
CREATE INDEX idx_refunds_status     ON refunds(refund_status);

-- ============================================================
-- 11. REVIEWS & RATINGS
-- ============================================================

CREATE TABLE reviews (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id      UUID            NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_id        UUID            REFERENCES orders(id) ON DELETE SET NULL,
    rating          SMALLINT        NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title           VARCHAR(255),
    body            TEXT,
    status          review_status_enum  NOT NULL DEFAULT 'pending',
    admin_reply     TEXT,
    replied_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    UNIQUE(product_id, user_id, order_id)
);

CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_user_id    ON reviews(user_id);
CREATE INDEX idx_reviews_status     ON reviews(status);

-- ============================================================
-- 12. CMS — STATIC PAGES
-- ============================================================

CREATE TABLE cms_pages (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug        page_slug_enum  UNIQUE NOT NULL,
    title       VARCHAR(255)    NOT NULL,
    content     TEXT            NOT NULL,
    updated_by  UUID            REFERENCES super_admins(id),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- Pre-populate required pages
INSERT INTO cms_pages (slug, title, content) VALUES
    ('about_us',            'About Us',           'Content coming soon.'),
    ('privacy_policy',      'Privacy Policy',     'Content coming soon.'),
    ('terms_and_conditions','Terms & Conditions',  'Content coming soon.');

-- ============================================================
-- 13. BANNERS & PROMOTIONAL SECTIONS
-- ============================================================

CREATE TABLE banners (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title           VARCHAR(255),
    image_url       TEXT            NOT NULL,
    link_url        TEXT,
    position        banner_position_enum NOT NULL DEFAULT 'homepage_hero',
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    sort_order      INTEGER         NOT NULL DEFAULT 0,
    valid_from      TIMESTAMPTZ,
    valid_until     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_banners_position   ON banners(position);
CREATE INDEX idx_banners_is_active  ON banners(is_active);

CREATE TABLE promotional_sections (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    identifier  VARCHAR(100)    UNIQUE NOT NULL,    -- e.g. 'homepage_featured_strip'
    title       VARCHAR(255),
    subtitle    TEXT,
    content     JSONB,                              -- flexible structured content
    is_active   BOOLEAN         NOT NULL DEFAULT TRUE,
    sort_order  INTEGER         NOT NULL DEFAULT 0,
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 14. FOOTER CONTENT
-- ============================================================

CREATE TABLE footer_sections (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title       VARCHAR(100)    NOT NULL,
    links       JSONB           NOT NULL DEFAULT '[]',   -- [{label, url}]
    sort_order  INTEGER         NOT NULL DEFAULT 0,
    is_active   BOOLEAN         NOT NULL DEFAULT TRUE,
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 15. NOTIFICATIONS
-- ============================================================

CREATE TABLE notification_templates (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100)    UNIQUE NOT NULL,
    type            notification_type_enum  NOT NULL,
    subject         VARCHAR(255),                   -- for email
    body            TEXT            NOT NULL,       -- supports {{variables}}
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TABLE notification_campaigns (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title           VARCHAR(255)    NOT NULL,
    template_id     UUID            REFERENCES notification_templates(id),
    type            notification_type_enum  NOT NULL,
    status          campaign_status_enum    NOT NULL DEFAULT 'draft',
    target_all      BOOLEAN         NOT NULL DEFAULT TRUE,
    target_filter   JSONB,                          -- e.g. {"is_active": true}
    scheduled_at    TIMESTAMPTZ,
    sent_at         TIMESTAMPTZ,
    created_by      UUID            REFERENCES super_admins(id),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TABLE notification_logs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_id     UUID            REFERENCES notification_campaigns(id),
    user_id         UUID            REFERENCES users(id) ON DELETE SET NULL,
    type            notification_type_enum  NOT NULL,
    title           VARCHAR(255),
    body            TEXT,
    is_sent         BOOLEAN         NOT NULL DEFAULT FALSE,
    sent_at         TIMESTAMPTZ,
    error           TEXT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notif_logs_user_id     ON notification_logs(user_id);
CREATE INDEX idx_notif_logs_campaign_id ON notification_logs(campaign_id);

-- FCM / push tokens per user device
CREATE TABLE user_push_tokens (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    fcm_token   TEXT            NOT NULL,
    device_type VARCHAR(20),   -- 'android' | 'ios'
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, fcm_token)
);

CREATE INDEX idx_push_tokens_user_id ON user_push_tokens(user_id);

-- ============================================================
-- 16. WISHLIST
-- ============================================================

CREATE TABLE wishlists (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id  UUID    NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    added_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

CREATE INDEX idx_wishlists_user_id ON wishlists(user_id);

-- ============================================================
-- 17. AUTOMATIC updated_at TRIGGER
-- ============================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    t TEXT;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'users', 'user_addresses', 'super_admins',
        'categories', 'products',
        'coupons', 'orders', 'payments', 'refunds',
        'reviews', 'cms_pages', 'banners',
        'promotional_sections', 'footer_sections',
        'notification_templates', 'notification_campaigns'
    ]
    LOOP
        EXECUTE format(
            'CREATE TRIGGER trg_%s_updated_at
             BEFORE UPDATE ON %s
             FOR EACH ROW EXECUTE FUNCTION set_updated_at();',
            t, t
        );
    END LOOP;
END;
$$;

-- ============================================================
-- 18. ORDER NUMBER GENERATOR
-- ============================================================

CREATE SEQUENCE order_number_seq START 1000;

CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_number := 'ORD-' || TO_CHAR(NOW(), 'YYYY') || '-' ||
                        LPAD(nextval('order_number_seq')::TEXT, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_orders_order_number
    BEFORE INSERT ON orders
    FOR EACH ROW
    WHEN (NEW.order_number IS NULL OR NEW.order_number = '')
    EXECUTE FUNCTION generate_order_number();

-- ============================================================
-- 19. SEED — SUPER ADMIN (change password after first login)
-- ============================================================
-- password_hash below is bcrypt of 'Admin@1234' — CHANGE THIS IMMEDIATELY

INSERT INTO super_admins (email, password_hash, name)
VALUES (
    'admin@dezign-lab.com',
    '$2b$12$placeholderHashReplaceThisWithRealBcryptHash',
    'Super Admin'
)
ON CONFLICT (email) DO NOTHING;

-- ============================================================
-- END OF SCHEMA
-- ============================================================