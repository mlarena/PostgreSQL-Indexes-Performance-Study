-- Те же запросы ПОСЛЕ создания индексов
SET search_path TO Btree;

-- Запрос 1: Диапазонный запрос по возрасту (должен использовать idx_users_age)
EXPLAIN (ANALYZE, BUFFERS) 
SELECT id, username, age, salary 
FROM users 
WHERE age BETWEEN 25 AND 35;

-- Запрос 2: Сортировка по зарплате (должен использовать idx_users_salary)
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, username, salary 
FROM users 
ORDER BY salary DESC 
LIMIT 100;

-- Запрос 3: Диапазон по дате (должен использовать idx_users_created_date)
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, username, created_date 
FROM users 
WHERE created_date BETWEEN '2023-01-01' AND '2023-12-31';

-- Запрос 4: JOIN с сортировкой (должен использовать idx_orders_amount)
EXPLAIN (ANALYZE, BUFFERS)
SELECT u.username, o.order_date, o.amount 
FROM users u
JOIN orders o ON u.id = o.user_id 
WHERE o.amount > 500
ORDER BY o.amount DESC
LIMIT 100;

-- Запрос 5: Группировка с фильтрацией (должен использовать idx_users_age или составной)
EXPLAIN (ANALYZE, BUFFERS)
SELECT age, COUNT(*) as user_count, AVG(salary) as avg_salary
FROM users 
WHERE age BETWEEN 30 AND 40
GROUP BY age
ORDER BY age;