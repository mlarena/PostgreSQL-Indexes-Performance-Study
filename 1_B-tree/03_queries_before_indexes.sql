-- Запросы ДО создания индексов с EXPLAIN ANALYZE
SET search_path TO Btree;

-- Запрос 1: Диапазонный запрос по возрасту
EXPLAIN (ANALYZE, BUFFERS) 
SELECT id, username, age, salary 
FROM users 
WHERE age BETWEEN 25 AND 35;

-- Запрос 2: Сортировка по зарплате
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, username, salary 
FROM users 
ORDER BY salary DESC 
LIMIT 100;

-- Запрос 3: Диапазон по дате
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, username, created_date 
FROM users 
WHERE created_date BETWEEN '2023-01-01' AND '2023-12-31';

-- Запрос 4: JOIN с сортировкой
EXPLAIN (ANALYZE, BUFFERS)
SELECT u.username, o.order_date, o.amount 
FROM users u
JOIN orders o ON u.id = o.user_id 
WHERE o.amount > 500
ORDER BY o.amount DESC
LIMIT 100;

-- Запрос 5: Группировка с фильтрацией
EXPLAIN (ANALYZE, BUFFERS)
SELECT age, COUNT(*) as user_count, AVG(salary) as avg_salary
FROM users 
WHERE age BETWEEN 30 AND 40
GROUP BY age
ORDER BY age;