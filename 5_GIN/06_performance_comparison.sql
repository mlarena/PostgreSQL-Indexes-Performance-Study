-- Сравнение производительности GIN индексов
SET search_path TO GIN;

-- Размеры индексов и таблиц
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size,
    pg_size_pretty(pg_relation_size((schemaname || '.' || tablename)::regclass)) as table_size,
    round(
        pg_relation_size(indexname::regclass)::numeric / 
        GREATEST(pg_relation_size((schemaname || '.' || tablename)::regclass), 1) * 100, 2
    ) as index_to_table_percent
FROM pg_indexes 
WHERE schemaname = 'gin'
ORDER BY pg_relation_size(indexname::regclass) DESC;

-- Статистика использования индексов
SELECT 
    schemaname,
    relname as table_name,
    indexrelname as index_name,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes 
WHERE schemaname = 'gin'
ORDER BY idx_scan DESC;

-- Сравнение GIN для разных типов данных
WITH index_stats AS (
    SELECT 
        indexrelname,
        idx_scan,
        idx_tup_read,
        idx_tup_fetch,
        pg_relation_size(indexrelid) as index_size_bytes
    FROM pg_stat_user_indexes 
    WHERE schemaname = 'gin'
)
SELECT 
    CASE 
        WHEN indexrelname LIKE '%tags%' THEN 'Array Tags'
        WHEN indexrelname LIKE '%json%' OR indexrelname LIKE '%data%' OR indexrelname LIKE '%metadata%' THEN 'JSONB Data'
        WHEN indexrelname LIKE '%search%' THEN 'Full-Text Search'
        WHEN indexrelname LIKE '%keywords%' THEN 'Array Keywords'
        WHEN indexrelname LIKE '%categories%' THEN 'Array Categories'
        WHEN indexrelname LIKE '%access%' THEN 'Array Access Control'
        WHEN indexrelname LIKE '%context%' THEN 'JSONB Context'
        WHEN indexrelname LIKE '%activity%' THEN 'JSONB Activity'
        WHEN indexrelname LIKE '%prices%' THEN 'Array Prices'
        ELSE 'Other GIN'
    END as data_type,
    COUNT(*) as index_count,
    SUM(idx_scan) as total_scans,
    pg_size_pretty(SUM(index_size_bytes)) as total_size,
    CASE 
        WHEN SUM(idx_scan) > 0 THEN 
            round(SUM(index_size_bytes)::numeric / SUM(idx_scan) / 1024, 2)
        ELSE 0 
    END as avg_kb_per_scan
FROM index_stats
GROUP BY data_type
ORDER BY total_scans DESC;

-- Эффективность для конкретных use cases
SELECT 
    'Array Operations' as use_case,
    (SELECT COUNT(*) FROM products) as total_products,
    (SELECT COUNT(*) FROM products WHERE tags && ARRAY['electronics']::text[]) as matching_products,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_products_tags_gin') as gin_scans;

SELECT 
    'JSONB Queries' as use_case,
    (SELECT COUNT(*) FROM user_profiles) as total_profiles,
    (SELECT COUNT(*) FROM user_profiles WHERE profile_data @> '{"personal": {"gender": "female"}}') as matching_profiles,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_profiles_data_gin') as gin_scans;

SELECT 
    'Full-Text Search' as use_case,
    (SELECT COUNT(*) FROM articles) as total_articles,
    (SELECT COUNT(*) FROM articles WHERE search_vector @@ to_tsquery('english', 'technology')) as matching_articles,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_articles_search_gin') as gin_scans;

SELECT 
    'JSONB Array Search' as use_case,
    (SELECT COUNT(*) FROM user_profiles) as total_profiles,
    (SELECT COUNT(*) FROM user_profiles WHERE activity_log @> '[{"action": "login"}]') as matching_profiles,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_profiles_activity_gin') as gin_scans;

-- Сравнение GIN и B-tree производительности
SELECT 
    'GIN Indexes' as index_type,
    COUNT(*) as total_indexes,
    SUM(pg_relation_size(indexname::regclass)) as total_size_bytes,
    pg_size_pretty(SUM(pg_relation_size(indexname::regclass))) as total_size,
    (SELECT SUM(idx_scan) FROM pg_stat_user_indexes WHERE schemaname = 'gin' AND indexrelname LIKE '%gin%') as total_scans
FROM pg_indexes 
WHERE schemaname = 'gin' AND indexname LIKE '%gin%'

UNION ALL

SELECT 
    'B-tree Indexes' as index_type,
    COUNT(*) as total_indexes,
    SUM(pg_relation_size(indexname::regclass)) as total_size_bytes,
    pg_size_pretty(SUM(pg_relation_size(indexname::regclass))) as total_size,
    (SELECT SUM(idx_scan) FROM pg_stat_user_indexes WHERE schemaname = 'gin' AND indexrelname LIKE '%btree%') as total_scans
FROM pg_indexes 
WHERE schemaname = 'gin' AND indexname LIKE '%btree%';

-- Анализ эффективности для сложных запросов
SELECT 
    'Complex JSONB Queries' as query_type,
    (SELECT COUNT(*) FROM documents WHERE properties @> '{"status": "approved", "department": "IT"}') as matching_documents,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_documents_properties_gin') as property_scans,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_documents_access_gin') as access_scans;

-- Анализ размера индексов по типам данных
SELECT 
    'Arrays' as data_type,
    COUNT(*) as index_count,
    pg_size_pretty(SUM(pg_relation_size(indexname::regclass))) as total_size
FROM pg_indexes 
WHERE schemaname = 'gin' AND (
    indexname LIKE '%tags%' OR 
    indexname LIKE '%categories%' OR 
    indexname LIKE '%keywords%' OR 
    indexname LIKE '%access%' OR
    indexname LIKE '%prices%'
)

UNION ALL

SELECT 
    'JSONB' as data_type,
    COUNT(*) as index_count,
    pg_size_pretty(SUM(pg_relation_size(indexname::regclass))) as total_size
FROM pg_indexes 
WHERE schemaname = 'gin' AND (
    indexname LIKE '%data%' OR 
    indexname LIKE '%metadata%' OR 
    indexname LIKE '%properties%' OR 
    indexname LIKE '%context%' OR
    indexname LIKE '%activity%'
)

UNION ALL

SELECT 
    'Full-Text Search' as data_type,
    COUNT(*) as index_count,
    pg_size_pretty(SUM(pg_relation_size(indexname::regclass))) as total_size
FROM pg_indexes 
WHERE schemaname = 'gin' AND indexname LIKE '%search%';

-- Рекомендации по использованию GIN
SELECT 
    tablename,
    indexname,
    idx_scan as scans,
    pg_size_pretty(pg_relation_size(indexrelid)) as size,
    CASE 
        WHEN idx_scan = 0 THEN 'UNUSED - Evaluate if needed for JSONB/array queries'
        WHEN idx_scan < 10 THEN 'RARELY USED - Monitor query patterns'
        WHEN pg_relation_size(indexrelid) > pg_relation_size(indrelid) * 0.4 THEN 'LARGE - Consider partial indexes'
        ELSE 'WELL UTILIZED'
    END as recommendation,
    CASE 
        WHEN indexname LIKE '%gin%' THEN
            CASE 
                WHEN indexname LIKE '%tags%' OR indexname LIKE '%categories%' THEN 'Good for array containment queries'
                WHEN indexname LIKE '%json%' OR indexname LIKE '%data%' THEN 'Good for JSONB path queries'
                WHEN indexname LIKE '%search%' THEN 'Essential for full-text search'
                WHEN indexname LIKE '%trgm%' THEN 'Good for pattern matching in arrays'
                WHEN indexname LIKE '%prices%' THEN 'Good for numeric array searches'
                ELSE 'General GIN usage'
            END
        ELSE 'B-tree comparison index'
    END as usage_note
FROM pg_stat_user_indexes 
JOIN pg_class ON pg_class.oid = indexrelid
WHERE schemaname = 'gin'
ORDER BY idx_scan DESC;