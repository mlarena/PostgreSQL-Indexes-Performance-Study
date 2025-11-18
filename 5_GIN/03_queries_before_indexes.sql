-- Запросы ДО создания индексов с EXPLAIN ANALYZE
SET search_path TO GIN;

-- Запрос 1: Поиск продуктов по тегам (массивы)
EXPLAIN (ANALYZE, BUFFERS) 
SELECT name, description, tags
FROM products 
WHERE tags && ARRAY['electronics', 'sale']::text[]
ORDER BY name
LIMIT 10;

-- Запрос 2: Поиск в JSONB данных профилей
EXPLAIN (ANALYZE, BUFFERS)
SELECT username, profile_data
FROM user_profiles 
WHERE profile_data @> '{"personal": {"gender": "female"}}'
LIMIT 10;

-- Запрос 3: Полнотекстовый поиск по статьям
EXPLAIN (ANALYZE, BUFFERS)
SELECT title, author, keywords
FROM articles 
WHERE to_tsvector('english', title || ' ' || content) @@ to_tsquery('english', 'technology & future')
ORDER BY title
LIMIT 10;

-- Запрос 4: Поиск документов по свойствам JSONB и массивам
EXPLAIN (ANALYZE, BUFFERS)
SELECT title, doc_type, properties
FROM documents 
WHERE properties @> '{"status": "approved"}' 
  AND access_control && ARRAY['internal', 'confidential']::text[]
LIMIT 10;

-- Запрос 5: Поиск по вложенным JSON полям
EXPLAIN (ANALYZE, BUFFERS)
SELECT username, profile_data->'personal' as personal_info
FROM user_profiles 
WHERE profile_data->'personal'->>'gender' = 'male'
  AND profile_data->'employment'->>'industry' = 'IT'
LIMIT 10;

-- Запрос 6: Поиск логов по тегам и уровню
EXPLAIN (ANALYZE, BUFFERS)
SELECT log_level, message, tags, created_at
FROM log_entries 
WHERE tags && ARRAY['security', 'error']::text[]
  AND log_level IN ('ERROR', 'CRITICAL')
ORDER BY created_at DESC
LIMIT 10;

-- Запрос 7: Поиск по массивам цен
EXPLAIN (ANALYZE, BUFFERS)
SELECT name, prices, categories
FROM products 
WHERE prices && ARRAY[99.99, 199.99]::numeric[]
LIMIT 10;

-- Запрос 8: Поиск по JSONB массиву активности
EXPLAIN (ANALYZE, BUFFERS)
SELECT username, activity_log
FROM user_profiles 
WHERE activity_log @> '[{"action": "login"}]'
LIMIT 10;