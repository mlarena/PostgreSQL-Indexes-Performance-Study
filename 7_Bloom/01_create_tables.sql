-- Создание таблиц для демонстрации Bloom индекса
-- Bloom фильтр оптимален для многоколоночной фильтрации с условиями OR

DROP SCHEMA IF EXISTS Bloom CASCADE;
CREATE SCHEMA Bloom;

SET search_path TO Bloom;

-- Таблица пользователей для многокритериального поиска
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    country_code VARCHAR(3),
    city VARCHAR(50),
    registration_source VARCHAR(20),
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица продуктов для фильтрации по множеству атрибутов
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    product_code VARCHAR(20) NOT NULL,
    name VARCHAR(200) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    supplier_id INTEGER NOT NULL,
    manufacturer VARCHAR(100),
    color VARCHAR(30),
    size VARCHAR(20),
    weight_kg NUMERIC(8,3),
    price NUMERIC(10,2) NOT NULL,
    in_stock BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица заказов для поиска по различным полям
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(30) NOT NULL,
    customer_id INTEGER NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    payment_method VARCHAR(30),
    shipping_method VARCHAR(30),
    warehouse_id INTEGER,
    sales_rep_id INTEGER,
    total_amount NUMERIC(12,2) NOT NULL,
    discount_amount NUMERIC(10,2) DEFAULT 0,
    order_date DATE NOT NULL,
    delivery_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица логов безопасности для многопользового поиска
CREATE TABLE security_logs (
    id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    user_id INTEGER,
    ip_address INET,
    user_agent TEXT,
    device_type VARCHAR(30),
    browser VARCHAR(50),
    os VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    success BOOLEAN NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица инвентаря для фильтрации по различным атрибутам
CREATE TABLE inventory (
    id BIGSERIAL PRIMARY KEY,
    sku VARCHAR(30) NOT NULL,
    product_id INTEGER NOT NULL,
    warehouse_id INTEGER NOT NULL,
    location_code VARCHAR(20),
    bin_number VARCHAR(10),
    quantity INTEGER NOT NULL,
    reserved_quantity INTEGER DEFAULT 0,
    reorder_level INTEGER,
    batch_number VARCHAR(50),
    expiry_date DATE,
    supplier_batch VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Комментарии о структуре таблиц
COMMENT ON TABLE users IS 'Таблица пользователей для тестирования Bloom фильтра по множеству полей';
COMMENT ON TABLE products IS 'Таблица продуктов для многокритериального поиска';
COMMENT ON TABLE orders IS 'Таблица заказов для фильтрации по различным атрибутам';
COMMENT ON TABLE security_logs IS 'Таблица логов безопасности для многопользового поиска';
COMMENT ON TABLE inventory IS 'Таблица инвентаря для фильтрации по различным атрибутам';

-- Создаем расширение для bloom индекса
CREATE EXTENSION IF NOT EXISTS bloom;