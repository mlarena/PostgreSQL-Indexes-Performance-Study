-- Создание B-tree индексов
SET search_path TO Btree;

-- Индекс 1: Возраст пользователей (для диапазонных запросов)
CREATE INDEX CONCURRENTLY idx_users_age ON users(age);

-- Индекс 2: Зарплата (для сортировки и диапазонов)
CREATE INDEX CONCURRENTLY idx_users_salary ON users(salary);

-- Индекс 3: Дата создания (для временных диапазонов)
CREATE INDEX CONCURRENTLY idx_users_created_date ON users(created_date);

-- Индекс 4: Составной индекс (возраст + зарплата)
CREATE INDEX CONCURRENTLY idx_users_age_salary ON users(age, salary);

-- Индекс 5: Сумма заказа (для JOIN запросов)
CREATE INDEX CONCURRENTLY idx_orders_amount ON orders(amount);

-- Индекс 6: Дата заказа
CREATE INDEX CONCURRENTLY idx_orders_date ON orders(order_date);

-- Индекс 7: Пользователь + дата заказа (для соединений)
CREATE INDEX CONCURRENTLY idx_orders_user_date ON orders(user_id, order_date);

-- Анализ таблиц для обновления статистики
ANALYZE users;
ANALYZE orders;