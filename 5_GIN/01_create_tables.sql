-- Создание таблиц для демонстрации GIN индекса
-- GIN (Generalized Inverted Index) оптимален для составных значений: массивы, JSONB, полнотекстовый поиск

DROP SCHEMA IF EXISTS GIN CASCADE;
CREATE SCHEMA GIN;

SET search_path TO GIN;

-- Таблица для тестирования индексации массивов
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    tags TEXT[] NOT NULL, -- массив тегов
    categories TEXT[] NOT NULL, -- массив категорий
    prices NUMERIC[] NOT NULL, -- массив цен для разных вариантов
    attributes JSONB, -- дополнительные атрибуты в JSON
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для тестирования JSONB индексации
CREATE TABLE user_profiles (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    profile_data JSONB NOT NULL, -- полный профиль в JSON
    preferences JSONB, -- настройки пользователя
    activity_log JSONB, -- JSON массив с активностью (изменили на JSONB вместо JSONB[])
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для тестирования полнотекстового поиска с GIN
CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL,
    content TEXT NOT NULL,
    author VARCHAR(100) NOT NULL,
    keywords TEXT[] NOT NULL, -- ключевые слова
    search_vector TSVECTOR, -- вектор для полнотекстового поиска
    metadata JSONB, -- метаданные статьи
    published_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для тестирования индексации составных документов
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    doc_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    properties JSONB NOT NULL, -- свойства документа
    attachments TEXT[], -- массив вложений
    access_control TEXT[] NOT NULL, -- права доступа
    version INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица для тестирования индексации сетевых данных
CREATE TABLE log_entries (
    id SERIAL PRIMARY KEY,
    log_level VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    context JSONB NOT NULL, -- контекст лога
    tags TEXT[] NOT NULL, -- теги для фильтрации
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Комментарии о структуре таблиц
COMMENT ON TABLE products IS 'Таблица продуктов для тестирования GIN с массивами и JSONB';
COMMENT ON TABLE user_profiles IS 'Таблица профилей для тестирования JSONB индексации';
COMMENT ON TABLE articles IS 'Таблица статей для полнотекстового поиска с GIN';
COMMENT ON TABLE documents IS 'Таблица документов для тестирования составных индексов';
COMMENT ON TABLE log_entries IS 'Таблица логов для тестирования индексации структурированных данных';