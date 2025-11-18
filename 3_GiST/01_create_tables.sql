-- Создание таблиц для демонстрации GiST индекса
-- GiST (Generalized Search Tree) оптимален для геоданных, полнотекстового поиска и сложных структур

DROP SCHEMA IF EXISTS GiST CASCADE;
CREATE SCHEMA GiST;

SET search_path TO GiST;

-- Таблица для полнотекстового поиска (документы) - ОСНОВНОЙ ТЕСТ
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    author VARCHAR(100) NOT NULL,
    publication_date DATE NOT NULL,
    tags TEXT[], -- массив тегов
    search_vector TSVECTOR, -- вектор для полнотекстового поиска
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для диапазонов (временных периодов) - работает без расширений
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    event_period TSRANGE NOT NULL, -- временной диапазон события
    location VARCHAR(100),
    max_participants INTEGER,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица сетевых адресов - работает без расширений
CREATE TABLE network_devices (
    id SERIAL PRIMARY KEY,
    device_name VARCHAR(100) NOT NULL,
    ip_range INET NOT NULL,
    mac_address MACADDR,
    location VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active'
);

-- Таблица с простыми геоданными (без PostGIS) - используем POINT из box
CREATE TABLE simple_locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    x_coord FLOAT NOT NULL, -- X координата
    y_coord FLOAT NOT NULL, -- Y координата  
    address TEXT,
    city VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Комментарии о структуре таблиц
COMMENT ON TABLE documents IS 'Таблица документов для полнотекстового поиска - основной тест GiST';
COMMENT ON TABLE events IS 'Таблица событий с временными диапазонами';
COMMENT ON TABLE network_devices IS 'Таблица сетевых устройств для тестирования INET индексации';
COMMENT ON TABLE simple_locations IS 'Таблица локаций с простыми координатами (без PostGIS)';

-- Создаем расширение btree_gist если не установлено (обычно доступно по умолчанию)
-- CREATE EXTENSION IF NOT EXISTS btree_gist;