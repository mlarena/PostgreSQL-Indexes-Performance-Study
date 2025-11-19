-- Запросы ДО создания индексов с EXPLAIN ANALYZE
SET search_path TO BRIN;

-- Запрос 1: Диапазонный поиск по временным рядам
EXPLAIN (ANALYZE, BUFFERS) 
SELECT sensor_id, measurement_time, value
FROM time_series_data 
WHERE measurement_time BETWEEN '2023-01-01' AND '2023-03-31'
  AND sensor_type = 'temperature'
ORDER BY measurement_time
LIMIT 100;

-- Запрос 2: Агрегация по датам для финансовых транзакций
EXPLAIN (ANALYZE, BUFFERS)
SELECT transaction_date, COUNT(*) as transaction_count, SUM(amount) as total_amount
FROM financial_transactions 
WHERE transaction_date BETWEEN '2023-01-01' AND '2023-12-31'
  AND amount > 0
GROUP BY transaction_date
ORDER BY transaction_date
LIMIT 100;

-- Запрос 3: Поиск логов по временному диапазону
EXPLAIN (ANALYZE, BUFFERS)
SELECT user_id, access_time, resource_path, status_code
FROM access_logs 
WHERE access_time BETWEEN '2023-06-01' AND '2023-06-30'
  AND status_code >= 400
ORDER BY access_time DESC
LIMIT 100;

-- Запрос 4: Анализ метрик системы за период
EXPLAIN (ANALYZE, BUFFERS)
SELECT server_id, metric_time, cpu_usage, memory_usage
FROM system_metrics 
WHERE metric_time BETWEEN '2023-10-01' AND '2023-10-07'
  AND cpu_usage > 80
ORDER BY metric_time, server_id
LIMIT 100;

-- Запрос 5: Географические данные по координатам
EXPLAIN (ANALYZE, BUFFERS)
SELECT location_type, latitude, longitude, temperature
FROM geographic_data 
WHERE latitude BETWEEN 55.0 AND 56.0
  AND longitude BETWEEN 37.0 AND 38.0
  AND recorded_date BETWEEN '2023-01-01' AND '2023-12-31'
ORDER BY recorded_date
LIMIT 100;

-- Запрос 6: Статистика по сенсорам за месяц
EXPLAIN (ANALYZE, BUFFERS)
SELECT sensor_id, sensor_type, 
       AVG(value) as avg_value,
       MIN(value) as min_value,
       MAX(value) as max_value
FROM time_series_data 
WHERE measurement_time BETWEEN '2023-05-01' AND '2023-05-31'
GROUP BY sensor_id, sensor_type
ORDER BY sensor_id
LIMIT 100;

-- Запрос 7: Поиск больших транзакций
EXPLAIN (ANALYZE, BUFFERS)
SELECT transaction_id, account_id, transaction_date, amount, description
FROM financial_transactions 
WHERE amount > 1000
  AND transaction_date BETWEEN '2023-01-01' AND '2023-12-31'
ORDER BY amount DESC
LIMIT 100;

-- Запрос 8: Анализ производительности системы
EXPLAIN (ANALYZE, BUFFERS)
SELECT metric_time,
       AVG(cpu_usage) as avg_cpu,
       AVG(memory_usage) as avg_memory,
       AVG(active_connections) as avg_connections
FROM system_metrics 
WHERE metric_time BETWEEN '2023-11-01' AND '2023-11-30'
GROUP BY DATE(metric_time)
ORDER BY DATE(metric_time)
LIMIT 100;