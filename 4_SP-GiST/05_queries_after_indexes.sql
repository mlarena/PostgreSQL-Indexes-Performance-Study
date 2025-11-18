-- Те же запросы ПОСЛЕ создания индексов
SET search_path TO SPGiST;

-- Запрос 1: Пространственный поиск точек в области (должен использовать SP-GiST)
EXPLAIN (ANALYZE, BUFFERS) 
SELECT location_name, coordinates, object_type
FROM spatial_data 
WHERE coordinates <@ box '(100,100,300,300)'
ORDER BY coordinates <-> point '(200,200)'
LIMIT 10;

-- Запрос 2: Поиск ближайших соседей в многомерном пространстве (должен использовать SP-GiST)
EXPLAIN (ANALYZE, BUFFERS)
SELECT data_point, category
FROM multidimensional_data 
WHERE data_point <-> point '(500,500)' < 100
ORDER BY data_point <-> point '(500,500)'
LIMIT 10;

-- Запрос 3: Поиск по префиксу в текстовых данных (должен использовать SP-GiST)
EXPLAIN (ANALYZE, BUFFERS)
SELECT word, frequency, part_of_speech
FROM text_data 
WHERE word LIKE 'auto%' AND language = 'english'
ORDER BY frequency DESC
LIMIT 10;

-- Запрос 4: Поиск в сетевых диапазонах (должен использовать SP-GiST)
EXPLAIN (ANALYZE, BUFFERS)
SELECT ip_address, hostname, country_code
FROM network_data 
WHERE ip_address <<= '192.168.1.0/24'::inet
ORDER BY ip_address
LIMIT 10;

-- Запрос 5: Поиск пересекающихся прямоугольников (должен использовать SP-GiST)
EXPLAIN (ANALYZE, BUFFERS)
SELECT box_name, bbox, object_type
FROM bounding_boxes 
WHERE bbox && box '(100,100,300,300)'
ORDER BY box_name
LIMIT 10;

-- Запрос 6: Комбинированный поиск (должен использовать составной SP-GiST)
EXPLAIN (ANALYZE, BUFFERS)
SELECT location_name, coordinates, object_type
FROM spatial_data 
WHERE coordinates <@ box '(200,200,600,600)'
  AND object_type IN ('building', 'landmark')
ORDER BY coordinates
LIMIT 10;

-- Дополнительные тесты для демонстрации возможностей SP-GiST

-- Запрос 7: Поиск по расстоянию (k-ближайших соседей)
EXPLAIN (ANALYZE, BUFFERS)
SELECT location_name, coordinates
FROM spatial_data 
ORDER BY coordinates <-> point '(250,250)'
LIMIT 5;

-- Запрос 8: Поиск по сложному префиксу
EXPLAIN (ANALYZE, BUFFERS)
SELECT word, language, frequency
FROM text_data 
WHERE word LIKE 'inter%tion'
ORDER BY frequency DESC
LIMIT 10;

-- Запрос 9: Поиск по вложенным сетевым диапазонам
EXPLAIN (ANALYZE, BUFFERS)
SELECT ip_address, network_range
FROM network_data 
WHERE ip_address <<= '10.0.0.0/8'::inet
  AND ip_address >>= '10.10.0.0/16'::inet
LIMIT 10;