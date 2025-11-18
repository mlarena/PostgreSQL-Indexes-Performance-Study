-- Создание таблиц для демонстрации B-tree индекса
-- B-tree оптимален для диапазонных запросов и сортировки

DROP SCHEMA IF EXISTS Btree CASCADE;
CREATE SCHEMA Btree;

SET search_path TO Btree;

-- Таблица пользователей для тестирования диапазонных запросов
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    age INTEGER NOT NULL,
    salary NUMERIC(10,2) NOT NULL,
    created_date DATE NOT NULL,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Таблица заказов для тестирования сортировки и соединений
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    product_category VARCHAR(50) NOT NULL
);

-- Комментарии о структуре таблиц
COMMENT ON TABLE users IS 'Таблица пользователей для тестирования B-tree индексов на числовых и строковых полях';
COMMENT ON TABLE orders IS 'Таблица заказов для тестирования составных индексов и соединений';