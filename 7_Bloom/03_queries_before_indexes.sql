-- Запросы ДО создания индексов с EXPLAIN ANALYZE
SET search_path TO Bloom;

-- Запрос 1: Многокритериальный поиск пользователей
EXPLAIN (ANALYZE, BUFFERS) 
SELECT username, email, first_name, last_name, country_code
FROM users 
WHERE username LIKE 'john%'
   OR email LIKE '%gmail.com'
   OR first_name = 'John'
   OR last_name = 'Smith'
   OR country_code = 'US'
LIMIT 100;

-- Запрос 2: Поиск продуктов по различным атрибутам
EXPLAIN (ANALYZE, BUFFERS)
SELECT product_code, name, brand, category, price
FROM products 
WHERE brand = 'Samsung'
   OR category = 'electronics'
   OR price BETWEEN 100 AND 500
   OR color = 'black'
   OR in_stock = true
LIMIT 100;

-- Запрос 3: Фильтрация заказов по разным полям
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_number, customer_id, order_status, total_amount
FROM orders 
WHERE order_status IN ('shipped', 'delivered')
   OR payment_method = 'credit_card'
   OR shipping_method = 'express'
   OR total_amount > 1000
   OR sales_rep_id = 25
LIMIT 100;

-- Запрос 4: Поиск в логах безопасности
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_type, user_id, ip_address, success
FROM security_logs 
WHERE event_type IN ('login', 'failed_login')
   OR ip_address <<= '192.168.1.0/24'::inet
   OR device_type = 'mobile'
   OR browser = 'Chrome'
   OR success = false
LIMIT 100;

-- Запрос 5: Поиск в инвентаре по различным критериям
EXPLAIN (ANALYZE, BUFFERS)
SELECT sku, product_id, warehouse_id, quantity
FROM inventory 
WHERE warehouse_id IN (1, 2, 3)
   OR location_code LIKE 'A%'
   OR quantity < 10
   OR reorder_level IS NOT NULL
   OR batch_number LIKE 'BATCH1%'
LIMIT 100;

-- Запрос 6: Комбинированный поиск с условиями OR
EXPLAIN (ANALYZE, BUFFERS)
SELECT username, registration_source, last_login
FROM users 
WHERE (country_code = 'US' AND city = 'New York')
   OR (registration_source = 'mobile' AND date_of_birth > '1990-01-01')
   OR last_login > '2023-01-01'
LIMIT 100;

-- Запрос 7: Сложный многопользовый поиск
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.name, p.brand, p.category, i.quantity, i.location_code
FROM products p
JOIN inventory i ON p.id = i.product_id
WHERE p.brand = 'Apple'
   OR p.category = 'electronics'
   OR i.warehouse_id = 1
   OR i.quantity > 100
   OR p.price < 500
LIMIT 100;