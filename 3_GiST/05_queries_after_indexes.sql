-- Те же запросы ПОСЛЕ создания индексов
SET search_path TO GiST;

-- Запрос 1: Полнотекстовый поиск (должен использовать GiST индекс)
EXPLAIN (ANALYZE, BUFFERS)
SELECT title, author, publication_date
FROM documents 
WHERE search_vector @@ to_tsquery('english', 'technology & future')
ORDER BY publication_date DESC
LIMIT 10;

-- Запрос 2: Поиск по временным диапазонам (должен использовать GiST индекс)
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_name, event_period, location
FROM events 
WHERE event_period && '[2024-01-01,2024-12-31]'::tsrange
ORDER BY lower(event_period)
LIMIT 10;

-- Запрос 3: Поиск по IP диапазону (должен использовать GiST индекс)
EXPLAIN (ANALYZE, BUFFERS)
SELECT device_name, ip_range, location
FROM network_devices 
WHERE ip_range << '192.168.1.100'::inet
ORDER BY ip_range
LIMIT 10;

-- Запрос 4: Поиск документов с определенными тегами (должен использовать GiST индекс)
EXPLAIN (ANALYZE, BUFFERS)
SELECT title, tags 
FROM documents 
WHERE tags && ARRAY['technology', 'science']::text[]
LIMIT 10;

-- Запрос 5: Поиск пересекающихся диапазонов (должен использовать GiST индекс)
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_name, event_period 
FROM events 
WHERE event_period && tsrange('2024-06-01', '2024-06-30')
ORDER BY event_period;

-- Запрос 6: Пространственный поиск с GiST (используя point)
EXPLAIN (ANALYZE, BUFFERS)
SELECT name, city, x_coord, y_coord
FROM simple_locations 
WHERE point(x_coord, y_coord) <@ box(point(55.7, 37.6), point(55.8, 37.7))
LIMIT 10;

-- Дополнительные тесты для сравнения

-- Запрос 7: Тот же поиск по координатам с B-tree (для сравнения)
EXPLAIN (ANALYZE, BUFFERS)
SELECT name, city, x_coord, y_coord
FROM simple_locations 
WHERE x_coord BETWEEN 55.7 AND 55.8 
  AND y_coord BETWEEN 37.6 AND 37.7
LIMIT 10;