-- ============================================================
-- ESQUEMA E-COMMERCE (con 5 malas prácticas intencionales)
-- ============================================================
-- Mala práctica 1: category_id en products NO tiene índice (FK sin index)
-- Mala práctica 2: order_date es VARCHAR(10) en vez de DATE
-- Mala práctica 3: Falta FK constraint en order_items → orders
-- Mala práctica 4: review_date es TEXT en vez de DATE
-- Mala práctica 5: orders no tiene índice en customer_id
-- ============================================================

CREATE TABLE categories (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    description TEXT,
    parent_id   INTEGER REFERENCES categories(id)
);
CREATE INDEX idx_categories_parent ON categories(parent_id);

CREATE TABLE products (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    description TEXT DEFAULT '',
    price       REAL NOT NULL CHECK(price > 0),
    stock       INTEGER NOT NULL DEFAULT 0,
    category_id INTEGER REFERENCES categories(id),  -- MALA PRÁCTICA 1: sin índice
    created_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE customers (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    email       TEXT NOT NULL UNIQUE,
    address     TEXT DEFAULT '',
    phone       TEXT DEFAULT '',
    created_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE orders (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL REFERENCES customers(id),  -- MALA PRÁCTICA 5: sin índice
    order_date  VARCHAR(10) NOT NULL,                        -- MALA PRÁCTICA 2: VARCHAR en vez de DATE
    total       REAL NOT NULL DEFAULT 0,
    status      TEXT NOT NULL DEFAULT 'pending',
    created_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE order_items (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id    INTEGER NOT NULL,                            -- MALA PRÁCTICA 3: sin FK constraint
    product_id  INTEGER NOT NULL REFERENCES products(id),
    quantity    INTEGER NOT NULL CHECK(quantity > 0),
    unit_price  REAL NOT NULL CHECK(unit_price > 0),
    created_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE payments (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id    INTEGER NOT NULL REFERENCES orders(id),
    amount      REAL NOT NULL CHECK(amount > 0),
    method      TEXT NOT NULL DEFAULT 'credit_card',
    status      TEXT NOT NULL DEFAULT 'pending',
    paid_at     TEXT,
    created_at  TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX idx_payments_order ON payments(order_id);

CREATE TABLE reviews (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id  INTEGER NOT NULL REFERENCES products(id),
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    rating      INTEGER NOT NULL CHECK(rating BETWEEN 1 AND 5),
    comment     TEXT DEFAULT '',
    review_date TEXT DEFAULT (datetime('now')),              -- MALA PRÁCTICA 4: TEXT en vez de DATE
    created_at  TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX idx_reviews_product ON reviews(product_id);
