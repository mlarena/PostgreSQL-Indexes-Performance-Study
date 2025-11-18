-- Запросы ДО создания индексов с EXPLAIN ANALYZE
SET search_path TO SPGiST;

-- Запрос 1: Пространственный поиск точек в области (квадродерево)
EXPLAIN (ANALYZE, BUFFERS) 
SELECT location_name, coordinates, object_type
FROM spatial_data 
WHERE coordinates <@ box '(100,100,300,300)'
ORDER BY coordinates <-> point '(200,200)'
LIMIT 10;

-- Запрос 2: Поиск ближайших соседей в многомерном пространстве (k-d дерево)
EXPLAIN (ANALYZE, BUFFERS)
SELECT data_point, category
FROM multidimensional_data 
WHERE data_point <-> point '(500,500)' < 100
ORDER BY data_point <-> point '(500,500)'
LIMIT 10;

-- Запрос 3: Поиск по префиксу в текстовых данных (префиксное дерево)
EXPLAIN (ANALYZE, BUFFERS)
SELECT word, frequency, part_of_speech
FROM text_data 
WHERE word LIKE 'auto%' AND language = 'english'
ORDER BY frequency DESC
LIMIT 10;

-- Запрос 4: Поиск в сетевых диапазонах (радиальное дерево)
EXPLAIN (ANALYZE, BUFFERS)
SELECT ip_address, hostname, country_code
FROM network_data 
WHERE ip_address <<= '192.168.1.0/24'::inet
ORDER BY ip_address
LIMIT 10;

-- Запрос 5: Поиск пересекающихся прямоугольников
EXPLAIN (ANALYZE, BUFFERS)
SELECT box_name, bbox, object_type
FROM bounding_boxes 
WHERE bbox && box '(100,100,300,300)'
ORDER BY box_name
LIMIT 10;

-- Запрос 6: Комбинированный поиск - точки в прямоугольнике с фильтром по типу
EXPLAIN (ANALYZE, BUFFERS)
SELECT location_name, coordinates, object_type
FROM spatial_data 
WHERE coordinates <@ box '(200,200,600,600)'
  AND object_type IN ('building', 'landmark')
ORDER BY coordinates
LIMIT 10;