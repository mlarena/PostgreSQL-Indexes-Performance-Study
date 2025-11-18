-- Сравнение производительности и анализ результатов
SET search_path TO Btree;

-- Размеры индексов
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size,
    pg_size_pretty(pg_relation_size(tablename::regclass)) as table_size
FROM pg_indexes 
WHERE schemaname = 'btree'
ORDER BY pg_relation_size(indexname::regclass) DESC;

-- Статистика использования индексов
SELECT 
    schemaname,
    relname as table_name,
    indexrelname as index_name,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes 
WHERE schemaname = 'btree'
ORDER BY idx_scan DESC;

-- Эффективность индексов (сколько раз использовался)
SELECT 
    indexrelname as index_name,
    idx_scan as scans,
    pg_size_pretty(pg_relation_size(indexrelid)) as size,
    CASE 
        WHEN idx_scan > 0 THEN 
            round((pg_relation_size(indexrelid)::numeric / idx_scan) / 1024, 2)
        ELSE 0 
    END as bytes_per_scan_kb
FROM pg_stat_user_indexes 
WHERE schemaname = 'btree'
ORDER BY bytes_per_scan_kb;