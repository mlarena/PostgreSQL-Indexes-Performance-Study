-- Создание таблиц для демонстрации Hash индекса
-- Hash оптимален для точечного поиска по равенству (=)

DROP SCHEMA IF EXISTS Hash CASCADE;
CREATE SCHEMA Hash;

SET search_path TO Hash;

-- Таблица продуктов для тестирования точечного поиска
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    supplier_id INTEGER NOT NULL,
    in_stock BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица пользователей сессий
CREATE TABLE user_sessions (
    session_id VARCHAR(64) NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL,
    ip_address INET NOT NULL,
    user_agent TEXT,
    is_valid BOOLEAN DEFAULT true
);

-- Таблица конфигурации
CREATE TABLE config (
    config_key VARCHAR(100) NOT NULL,
    config_value TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE products IS 'Таблица продуктов для тестирования Hash индексов на уникальных кодах';
COMMENT ON TABLE user_sessions IS 'Таблица сессий для тестирования поиска по идентификаторам';
COMMENT ON TABLE config IS 'Таблица конфигурации для точечного поиска по ключам';