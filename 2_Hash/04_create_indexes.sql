-- Создание Hash индексов
SET search_path TO Hash;

-- Индекс 1: Hash индекс на коде продукта (точечный поиск)
CREATE INDEX CONCURRENTLY idx_products_code_hash ON products USING HASH (product_code);

-- Индекс 2: Hash индекс на ID сессии
CREATE INDEX CONCURRENTLY idx_sessions_id_hash ON user_sessions USING HASH (session_id);

-- Индекс 3: Hash индекс на ключе конфигурации
CREATE INDEX CONCURRENTLY idx_config_key_hash ON config USING HASH (config_key);

-- Для сравнения: B-tree индекс на том же поле
CREATE INDEX CONCURRENTLY idx_products_code_btree ON products (product_code);

-- Hash индекс на категории (менее эффективен из-за низкой кардинальности)
CREATE INDEX CONCURRENTLY idx_products_category_hash ON products USING HASH (category);

-- Анализ таблиц для обновления статистики
ANALYZE products;
ANALYZE user_sessions;
ANALYZE config;