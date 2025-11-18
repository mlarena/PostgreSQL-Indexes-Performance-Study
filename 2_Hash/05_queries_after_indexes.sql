-- Те же запросы ПОСЛЕ создания индексов
SET search_path TO Hash;

-- Запрос 1: Точечный поиск по коду продукта (должен использовать Hash индекс)
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM products WHERE product_code = 'PROD123456';

-- Запрос 2: Поиск сессии по ID (должен использовать Hash индекс)
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM user_sessions WHERE session_id = 'abc123def456';

-- Запрос 3: Поиск конфигурации по ключу (должен использовать Hash индекс)
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM config WHERE config_key = 'app.name';

-- Запрос 4: Поиск продуктов по категории (сравнение Hash vs B-tree)
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM products WHERE category = 'electronics';

-- Запрос 5: Поиск по нескольким точным значениям
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM products 
WHERE product_code IN ('PROD123456', 'PROD654321', 'PROD111111');

-- Дополнительные тесты для сравнения производительности
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM products WHERE product_code = 'PROD123456';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM products WHERE product_code LIKE 'PROD123%';