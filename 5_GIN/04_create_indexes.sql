-- Создание GIN индексов
SET search_path TO GIN;

-- Индекс 1: GIN для массивов тегов в продуктах
CREATE INDEX CONCURRENTLY idx_products_tags_gin ON products USING GIN (tags);

-- Индекс 2: GIN для массивов категорий
CREATE INDEX CONCURRENTLY idx_products_categories_gin ON products USING GIN (categories);

-- Индекс 3: GIN для JSONB профилей
CREATE INDEX CONCURRENTLY idx_profiles_data_gin ON user_profiles USING GIN (profile_data);

-- Индекс 4: GIN для полнотекстового поиска
CREATE INDEX CONCURRENTLY idx_articles_search_gin ON articles USING GIN (search_vector);

-- Индекс 5: GIN для ключевых слов (массивов)
CREATE INDEX CONCURRENTLY idx_articles_keywords_gin ON articles USING GIN (keywords);

-- Индекс 6: GIN для JSONB метаданных
CREATE INDEX CONCURRENTLY idx_articles_metadata_gin ON articles USING GIN (metadata);

-- Индекс 7: GIN для JSONB свойств документов
CREATE INDEX CONCURRENTLY idx_documents_properties_gin ON documents USING GIN (properties);

-- Индекс 8: GIN для массивов контроля доступа
CREATE INDEX CONCURRENTLY idx_documents_access_gin ON documents USING GIN (access_control);

-- Индекс 9: GIN для тегов логов
CREATE INDEX CONCURRENTLY idx_logs_tags_gin ON log_entries USING GIN (tags);

-- Индекс 10: GIN для JSONB контекста логов
CREATE INDEX CONCURRENTLY idx_logs_context_gin ON log_entries USING GIN (context);

-- Индекс 11: GIN для JSONB активности пользователей
CREATE INDEX CONCURRENTLY idx_profiles_activity_gin ON user_profiles USING GIN (activity_log);

-- Индекс 12: GIN для массивов цен
CREATE INDEX CONCURRENTLY idx_products_prices_gin ON products USING GIN (prices);

-- Специализированные GIN индексы

-- Индекс 13: GIN для JSONB пути (только определенные поля)
CREATE INDEX CONCURRENTLY idx_profiles_gender_gin ON user_profiles USING GIN ((profile_data->'personal'->'gender'));

-- Индекс 14: GIN для массивов с использованием gin_trgm_ops (похожие теги)
CREATE INDEX CONCURRENTLY idx_products_tags_trgm_gin ON products USING GIN (tags gin_trgm_ops);

-- Индекс 15: Составной GIN индекс (JSONB + массив)
CREATE INDEX CONCURRENTLY idx_documents_composite_gin ON documents USING GIN (properties, access_control);

-- Для сравнения: B-tree индексы на тех же полях
CREATE INDEX CONCURRENTLY idx_products_name_btree ON products USING BTREE (name);
CREATE INDEX CONCURRENTLY idx_profiles_username_btree ON user_profiles USING BTREE (username);
CREATE INDEX CONCURRENTLY idx_articles_author_btree ON articles USING BTREE (author);
CREATE INDEX CONCURRENTLY idx_logs_level_btree ON log_entries USING BTREE (log_level);

-- Анализ таблиц для обновления статистики
ANALYZE products;
ANALYZE user_profiles;
ANALYZE articles;
ANALYZE documents;
ANALYZE log_entries;