-- Запросы ДО создания индексов с EXPLAIN ANALYZE
SET search_path TO Hash;

-- Запрос 1: Точечный поиск по коду продукта
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM products WHERE product_code = 'PROD123456';

-- Запрос 2: Поиск сессии по ID
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM user_sessions WHERE session_id = 'abc123def456';

-- Запрос 3: Поиск конфигурации по ключу
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM config WHERE config_key = 'app.name';

-- Запрос 4: Поиск продуктов по категории (для сравнения с Hash)
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM products WHERE category = 'electronics';

-- Запрос 5: Поиск по нескольким точным значениям
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM products 
WHERE product_code IN ('PROD123456', 'PROD654321', 'PROD111111');