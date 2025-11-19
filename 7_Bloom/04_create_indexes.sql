-- Создание Bloom индексов
SET search_path TO Bloom;

-- Проверяем, что расширение bloom установлено
CREATE EXTENSION IF NOT EXISTS bloom;

-- Индекс 1: Bloom для многокритериального поиска пользователей
CREATE INDEX CONCURRENTLY idx_users_bloom ON users USING bloom (
    username, email, first_name, last_name, country_code, city, registration_source
);

-- Индекс 2: Bloom для фильтрации продуктов
CREATE INDEX CONCURRENTLY idx_products_bloom ON products USING bloom (
    brand, category, subcategory, color, size, in_stock
);

-- Индекс 3: Bloom для поиска заказов
CREATE INDEX CONCURRENTLY idx_orders_bloom ON orders USING bloom (
    order_status, payment_method, shipping_method, warehouse_id, sales_rep_id
);

-- Индекс 4: Bloom для логов безопасности
CREATE INDEX CONCURRENTLY idx_security_logs_bloom ON security_logs USING bloom (
    event_type, device_type, browser, os, country, success
);

-- Индекс 5: Bloom для инвентаря
CREATE INDEX CONCURRENTLY idx_inventory_bloom ON inventory USING bloom (
    warehouse_id, location_code, bin_number, reorder_level, batch_number
);

-- Специализированные Bloom индексы с настройками

-- Индекс 6: Bloom с увеличенным размером для пользователей
CREATE INDEX CONCURRENTLY idx_users_bloom_large ON users USING bloom (
    username, email, first_name, last_name, country_code, city, registration_source
) WITH (length=80);

-- Индекс 7: Bloom для числовых полей продуктов
CREATE INDEX CONCURRENTLY idx_products_numeric_bloom ON products USING bloom (
    supplier_id, (price::integer), (weight_kg::integer)
);

-- Для сравнения: B-tree индексы на отдельных полях
CREATE INDEX CONCURRENTLY idx_users_username_btree ON users USING BTREE (username);
CREATE INDEX CONCURRENTLY idx_users_email_btree ON users USING BTREE (email);
CREATE INDEX CONCURRENTLY idx_users_country_btree ON users USING BTREE (country_code);

CREATE INDEX CONCURRENTLY idx_products_brand_btree ON products USING BTREE (brand);
CREATE INDEX CONCURRENTLY idx_products_category_btree ON products USING BTREE (category);
CREATE INDEX CONCURRENTLY idx_products_price_btree ON products USING BTREE (price);

CREATE INDEX CONCURRENTLY idx_orders_status_btree ON orders USING BTREE (order_status);
CREATE INDEX CONCURRENTLY idx_orders_payment_btree ON orders USING BTREE (payment_method);

-- Составные B-tree индексы для сравнения
CREATE INDEX CONCURRENTLY idx_users_composite_btree ON users USING BTREE (username, email, country_code);
CREATE INDEX CONCURRENTLY idx_products_composite_btree ON products USING BTREE (brand, category, in_stock);

-- Анализ таблиц для обновления статистики
ANALYZE users;
ANALYZE products;
ANALYZE orders;
ANALYZE security_logs;
ANALYZE inventory;