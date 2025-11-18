-- Сравнение производительности GiST индексов
SET search_path TO GiST;

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
WHERE schemaname = 'gist'
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
WHERE schemaname = 'gist'
ORDER BY idx_scan DESC;

-- Эффективность GiST индексов для разных типов данных
WITH index_stats AS (
    SELECT 
        indexrelname,
        idx_scan,
        idx_tup_read,
        idx_tup_fetch,
        pg_relation_size(indexrelid) as index_size_bytes
    FROM pg_stat_user_indexes 
    WHERE schemaname = 'gist'
)
SELECT 
    CASE 
        WHEN indexrelname LIKE '%search_vector%' THEN 'Full-Text Search'
        WHEN indexrelname LIKE '%period%' THEN 'Temporal Ranges'
        WHEN indexrelname LIKE '%ip_range%' THEN 'Network Ranges'
        WHEN indexrelname LIKE '%tags%' THEN 'Array Operations'
        WHEN indexrelname LIKE '%coords%' THEN 'Spatial Data'
        WHEN indexrelname LIKE '%btree%' THEN 'B-tree Comparison'
        ELSE 'Other GiST'
    END as index_type,
    indexrelname as index_name,
    idx_scan as scans,
    idx_tup_read as tuples_read,
    pg_size_pretty(index_size_bytes) as size,
    CASE 
        WHEN idx_scan > 0 THEN 
            round((index_size_bytes::numeric / idx_scan) / 1024, 2)
        ELSE 0 
    END as kb_per_scan
FROM index_stats
ORDER BY idx_scan DESC;

-- Сравнение GiST и B-tree индексов
SELECT 
    'GiST Index' as index_type,
    COUNT(*) as index_count,
    SUM(pg_relation_size(indexname::regclass)) as total_size_bytes,
    pg_size_pretty(SUM(pg_relation_size(indexname::regclass))) as total_size
FROM pg_indexes 
WHERE schemaname = 'gist' AND indexname LIKE '%gist%'

UNION ALL

SELECT 
    'B-tree Index' as index_type,
    COUNT(*) as index_count,
    SUM(pg_relation_size(indexname::regclass)) as total_size_bytes,
    pg_size_pretty(SUM(pg_relation_size(indexname::regclass))) as total_size
FROM pg_indexes 
WHERE schemaname = 'gist' AND indexname LIKE '%btree%';

-- Детальное сравнение по типам данных
SELECT 
    tablename,
    indexname,
    CASE 
        WHEN indexname LIKE '%gist%' THEN 'GiST'
        WHEN indexname LIKE '%btree%' THEN 'B-tree'
        ELSE 'Other'
    END as index_kind,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as size,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = indexname) as scans
FROM pg_indexes 
WHERE schemaname = 'gist'
ORDER BY tablename, index_kind;

-- Анализ эффективности для полнотекстового поиска
SELECT 
    'Full-Text Search' as test_case,
    (SELECT COUNT(*) FROM documents) as total_documents,
    (SELECT COUNT(*) FROM documents WHERE search_vector @@ to_tsquery('english', 'technology')) as matching_documents,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_documents_search_vector_gist') as gist_index_scans,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_documents_publication_date_btree') as btree_index_scans;

-- Анализ эффективности для временных диапазонов
SELECT 
    'Temporal Ranges' as test_case,
    (SELECT COUNT(*) FROM events) as total_events,
    (SELECT COUNT(*) FROM events WHERE event_period && '[2024-01-01,2024-12-31]'::tsrange) as matching_events,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_events_period_gist') as gist_index_scans;

-- Анализ эффективности для сетевых адресов
SELECT 
    'Network Ranges' as test_case,
    (SELECT COUNT(*) FROM network_devices) as total_devices,
    (SELECT COUNT(*) FROM network_devices WHERE ip_range << '192.168.1.100'::inet) as matching_devices,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_network_ip_range_gist') as gist_index_scans;

-- Статистика по использованию операторов для GiST индексов
SELECT 
    tablename,
    indexname,
    (pg_stat_get_blocks_fetched(indexrelid) - pg_stat_get_blocks_hit(indexrelid)) as disk_reads,
    pg_stat_get_blocks_hit(indexrelid) as cache_hits,
    CASE 
        WHEN (pg_stat_get_blocks_fetched(indexrelid) > 0) THEN
            round(pg_stat_get_blocks_hit(indexrelid)::numeric / pg_stat_get_blocks_fetched(indexrelid) * 100, 2)
        ELSE 0
    END as cache_hit_rate
FROM pg_stat_user_indexes 
WHERE schemaname = 'gist' AND idx_scan > 0;

-- Рекомендации по оптимизации на основе статистики
SELECT 
    indexrelname as index_name,
    idx_scan as scans,
    pg_size_pretty(pg_relation_size(indexrelid)) as size,
    CASE 
        WHEN idx_scan = 0 THEN 'UNUSED - Consider dropping'
        WHEN idx_scan < 10 THEN 'RARELY USED - Monitor'
        WHEN pg_relation_size(indexrelid) > pg_relation_size(indrelid) * 0.5 THEN 'LARGE - Consider optimization'
        ELSE 'WELL USED'
    END as recommendation
FROM pg_stat_user_indexes 
JOIN pg_class ON pg_class.oid = indexrelid
WHERE schemaname = 'gist'
ORDER BY idx_scan;