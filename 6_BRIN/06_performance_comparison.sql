-- Сравнение производительности BRIN индексов
SET search_path TO BRIN;

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
WHERE schemaname = 'brin'
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
WHERE schemaname = 'brin'
ORDER BY idx_scan DESC;

-- Сравнение BRIN и B-tree для разных типов данных
WITH index_stats AS (
    SELECT 
        indexrelname,
        idx_scan,
        idx_tup_read,
        idx_tup_fetch,
        pg_relation_size(indexrelid) as index_size_bytes
    FROM pg_stat_user_indexes 
    WHERE schemaname = 'brin'
)
SELECT 
    CASE 
        WHEN indexrelname LIKE '%brin%' THEN 'BRIN'
        WHEN indexrelname LIKE '%btree%' THEN 'B-tree'
        ELSE 'Other'
    END as index_type,
    CASE 
        WHEN indexrelname LIKE '%time%' OR indexrelname LIKE '%date%' THEN 'Temporal Data'
        WHEN indexrelname LIKE '%geo%' OR indexrelname LIKE '%lat%' OR indexrelname LIKE '%long%' THEN 'Geographic Data'
        WHEN indexrelname LIKE '%amount%' OR indexrelname LIKE '%cpu%' THEN 'Numeric Data'
        WHEN indexrelname LIKE '%sensor%' OR indexrelname LIKE '%server%' THEN 'Sequential IDs'
        ELSE 'Other Data'
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
GROUP BY index_type, data_type
ORDER BY data_type, index_type;

-- Эффективность для конкретных use cases
SELECT 
    'Temporal Range Queries' as use_case,
    (SELECT COUNT(*) FROM time_series_data) as total_records,
    (SELECT COUNT(*) FROM time_series_data WHERE measurement_time BETWEEN '2023-01-01' AND '2023-03-31') as matching_records,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_time_series_measurement_time_brin') as brin_scans,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_time_series_measurement_time_btree') as btree_scans;

SELECT 
    'Date-based Aggregation' as use_case,
    (SELECT COUNT(*) FROM financial_transactions) as total_records,
    (SELECT COUNT(*) FROM financial_transactions WHERE transaction_date BETWEEN '2023-01-01' AND '2023-12-31') as matching_records,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_transactions_date_brin') as brin_scans,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_transactions_date_btree') as btree_scans;

-- Сравнение размера BRIN и B-tree индексов
SELECT 
    'BRIN Indexes' as index_type,
    COUNT(*) as total_indexes,
    SUM(pg_relation_size(indexname::regclass)) as total_size_bytes,
    pg_size_pretty(SUM(pg_relation_size(indexname::regclass))) as total_size
FROM pg_indexes 
WHERE schemaname = 'brin' AND indexname LIKE '%brin%'

UNION ALL

SELECT 
    'B-tree Indexes' as index_type,
    COUNT(*) as total_indexes,
    SUM(pg_relation_size(indexname::regclass)) as total_size_bytes,
    pg_size_pretty(SUM(pg_relation_size(indexname::regclass))) as total_size
FROM pg_indexes 
WHERE schemaname = 'brin' AND indexname LIKE '%btree%';

-- Анализ эффективности BRIN для разных размеров диапазонов
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
WHERE schemaname = 'brin' AND idx_scan > 0;

-- Рекомендации по использованию BRIN
SELECT 
    tablename,
    indexname,
    idx_scan as scans,
    pg_size_pretty(pg_relation_size(indexrelid)) as size,
    CASE 
        WHEN idx_scan = 0 THEN 'UNUSED - Consider for large tables with correlated data'
        WHEN idx_scan < 5 THEN 'RARELY USED - Evaluate query patterns'
        WHEN pg_relation_size(indexrelid) > pg_relation_size(indrelid) * 0.1 THEN 'LARGE - Review pages_per_range setting'
        ELSE 'WELL UTILIZED'
    END as recommendation,
    CASE 
        WHEN indexname LIKE '%brin%' THEN
            CASE 
                WHEN tablename = 'time_series_data' AND indexname LIKE '%time%' THEN 'Ideal for time-series data'
                WHEN tablename = 'financial_transactions' AND indexname LIKE '%date%' THEN 'Good for date-range queries'
                WHEN tablename = 'access_logs' AND indexname LIKE '%time%' THEN 'Effective for log analysis'
                WHEN tablename = 'system_metrics' AND indexname LIKE '%time%' THEN 'Suitable for monitoring data'
                WHEN tablename = 'geographic_data' AND (indexname LIKE '%lat%' OR indexname LIKE '%long%') THEN 'Useful for geographic ranges'
                ELSE 'General BRIN usage'
            END
        ELSE 'B-tree comparison index'
    END as usage_note
FROM pg_stat_user_indexes 
JOIN pg_class ON pg_class.oid = indexrelid
WHERE schemaname = 'brin'
ORDER BY idx_scan DESC;

-- Анализ корреляции данных для BRIN эффективности
SELECT 
    tablename,
    attname,
    correlation
FROM pg_stats 
WHERE schemaname = 'brin' 
  AND (attname LIKE '%time%' OR attname LIKE '%date%' OR attname IN ('latitude', 'longitude', 'amount', 'cpu_usage'))
ORDER BY abs(correlation) DESC;