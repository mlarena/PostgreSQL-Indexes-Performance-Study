-- Создание таблиц для демонстрации SP-GiST индекса
-- SP-GiST (Space-Partitioned Generalized Search Tree) оптимален для нерегулярных структур данных

DROP SCHEMA IF EXISTS SPGiST CASCADE;
CREATE SCHEMA SPGiST;

SET search_path TO SPGiST;

-- Таблица для тестирования индексации по квадродеревьям (геоданные)
CREATE TABLE spatial_data (
    id SERIAL PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    coordinates POINT NOT NULL, -- точка на плоскости
    object_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для тестирования индексации по k-d деревьям (многомерные данные)
CREATE TABLE multidimensional_data (
    id SERIAL PRIMARY KEY,
    data_point POINT NOT NULL, -- 2D точка
    category VARCHAR(50) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для тестирования индексации по префиксным деревьям (строки)
CREATE TABLE text_data (
    id SERIAL PRIMARY KEY,
    word VARCHAR(100) NOT NULL,
    language VARCHAR(20) NOT NULL,
    frequency INTEGER NOT NULL,
    part_of_speech VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для тестирования индексации по радиальным деревьям (сетевые данные)
CREATE TABLE network_data (
    id SERIAL PRIMARY KEY,
    ip_address INET NOT NULL,
    hostname VARCHAR(100),
    network_range CIDR,
    country_code VARCHAR(3),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для тестирования индексации по прямоугольникам (bounding boxes)
CREATE TABLE bounding_boxes (
    id SERIAL PRIMARY KEY,
    box_name VARCHAR(100) NOT NULL,
    bbox BOX NOT NULL, -- прямоугольник (x1,y1,x2,y2)
    object_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Комментарии о структуре таблиц
COMMENT ON TABLE spatial_data IS 'Таблица для тестирования SP-GiST с квадродеревьями (точки)';
COMMENT ON TABLE multidimensional_data IS 'Таблица для тестирования SP-GiST с k-d деревьями (многомерные данные)';
COMMENT ON TABLE text_data IS 'Таблица для тестирования SP-GiST с префиксными деревьями (строки)';
COMMENT ON TABLE network_data IS 'Таблица для тестирования SP-GiST с радиальными деревьями (сетевые адреса)';
COMMENT ON TABLE bounding_boxes IS 'Таблица для тестирования SP-GiST с прямоугольниками';