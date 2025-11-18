-- Те же запросы ПОСЛЕ создания индексов
SET search_path TO GIN;

-- Запрос 1: Поиск продуктов по тегам (должен использовать GIN)
EXPLAIN (ANALYZE, BUFFERS) 
SELECT name, description, tags
FROM products 
WHERE tags && ARRAY['electronics', 'sale']::text[]
ORDER BY name
LIMIT 10;

-- Запрос 2: Поиск в JSONB данных профилей (должен использовать GIN)
EXPLAIN (ANALYZE, BUFFERS)
SELECT username, profile_data
FROM user_profiles 
WHERE profile_data @> '{"personal": {"gender": "female"}}'
LIMIT 10;

-- Запрос 3: Полнотекстовый поиск по статьям (должен использовать GIN)
EXPLAIN (ANALYZE, BUFFERS)
SELECT title, author, keywords
FROM articles 
WHERE search_vector @@ to_tsquery('english', 'technology & future')
ORDER BY title
LIMIT 10;

-- Запрос 4: Поиск документов по свойствам JSONB и массивам (должен использовать GIN)
EXPLAIN (ANALYZE, BUFFERS)
SELECT title, doc_type, properties
FROM documents 
WHERE properties @> '{"status": "approved"}' 
  AND access_control && ARRAY['internal', 'confidential']::text[]
LIMIT 10;

-- Запрос 5: Поиск по вложенным JSON полям (должен использовать GIN)
EXPLAIN (ANALYZE, BUFFERS)
SELECT username, profile_data->'personal' as personal_info
FROM user_profiles 
WHERE profile_data->'personal'->>'gender' = 'male'
  AND profile_data->'employment'->>'industry' = 'IT'
LIMIT 10;

-- Запрос 6: Поиск логов по тегам и уровню (должен использовать GIN)
EXPLAIN (ANALYZE, BUFFERS)
SELECT log_level, message, tags, created_at
FROM log_entries 
WHERE tags && ARRAY['security', 'error']::text[]
  AND log_level IN ('ERROR', 'CRITICAL')
ORDER BY created_at DESC
LIMIT 10;

-- Запрос 7: Поиск по массивам цен (должен использовать GIN)
EXPLAIN (ANALYZE, BUFFERS)
SELECT name, prices, categories
FROM products 
WHERE prices && ARRAY[99.99, 199.99]::numeric[]
LIMIT 10;

-- Запрос 8: Поиск по JSONB массиву активности (должен использовать GIN)
EXPLAIN (ANALYZE, BUFFERS)
SELECT username, activity_log
FROM user_profiles 
WHERE activity_log @> '[{"action": "login"}]'
LIMIT 10;

-- Дополнительные тесты для демонстрации возможностей GIN

-- Запрос 9: Поиск по нескольким JSONB условиям
EXPLAIN (ANALYZE, BUFFERS)
SELECT title, properties
FROM documents 
WHERE properties @> '{"status": "approved", "department": "IT"}'
LIMIT 10;

-- Запрос 10: Поиск по частичному совпадению в массивах (триграммы)
EXPLAIN (ANALYZE, BUFFERS)
SELECT name, tags
FROM products 
WHERE tags && ARRAY['elec%']::text[]
LIMIT 10;

-- Запрос 11: Комбинированный поиск по разным типам данных
EXPLAIN (ANALYZE, BUFFERS)
SELECT a.title, a.author, p.name as product_name
FROM articles a
JOIN products p ON a.keywords && p.tags
WHERE a.search_vector @@ to_tsquery('english', 'innovation')
  AND p.tags && ARRAY['technology']::text[]
LIMIT 10;

-- Запрос 12: Поиск по сложным JSONB структурам
EXPLAIN (ANALYZE, BUFFERS)
SELECT username, profile_data->'employment' as employment_info
FROM user_profiles 
WHERE profile_data @> '{"employment": {"industry": "IT"}}'
  AND profile_data->'personal'->>'gender' = 'female'
LIMIT 10;

-- Запрос 13: Поиск по вложенным массивам в JSONB
EXPLAIN (ANALYZE, BUFFERS)
SELECT username, preferences
FROM user_profiles 
WHERE preferences @> '{"notifications": {"email": true}}'
LIMIT 10;