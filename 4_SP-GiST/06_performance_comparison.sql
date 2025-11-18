-- Сравнение производительности SP-GiST индексов
SET search_path TO SPGiST;

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
WHERE schemaname = 'spgist'
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
WHERE schemaname = 'spgist'
ORDER BY idx_scan DESC;

-- Сравнение SP-GiST и B-tree для разных типов данных
WITH index_stats AS (
    SELECT 
        indexrelname,
        idx_scan,
        idx_tup_read,
        idx_tup_fetch,
        pg_relation_size(indexrelid) as index_size_bytes
    FROM pg_stat_user_indexes 
    WHERE schemaname = 'spgist'
)
SELECT 
    CASE 
        WHEN indexrelname LIKE '%spgist%' THEN 'SP-GiST'
        WHEN indexrelname LIKE '%btree%' THEN 'B-tree'
        ELSE 'Other'
    END as index_type,
    CASE 
        WHEN indexrelname LIKE '%word%' THEN 'Text Prefix Search'
        WHEN indexrelname LIKE '%ip%' THEN 'Network Ranges'
        WHEN indexrelname LIKE '%point%' THEN 'Multidimensional Data'
        WHEN indexrelname LIKE '%coord%' THEN 'Spatial Data'
        WHEN indexrelname LIKE '%bbox%' THEN 'Bounding Boxes'
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
    'Spatial Queries' as use_case,
    (SELECT COUNT(*) FROM spatial_data) as total_records,
    (SELECT COUNT(*) FROM spatial_data WHERE coordinates <@ box '(100,100,300,300)') as matching_records,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_spatial_coordinates_spgist') as spgist_scans;

SELECT 
    'Text Prefix Search' as use_case,
    (SELECT COUNT(*) FROM text_data) as total_records,
    (SELECT COUNT(*) FROM text_data WHERE word LIKE 'auto%') as matching_records,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_text_word_spgist') as spgist_scans,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_text_word_btree') as btree_scans;

SELECT 
    'Network Range Queries' as use_case,
    (SELECT COUNT(*) FROM network_data) as total_records,
    (SELECT COUNT(*) FROM network_data WHERE ip_address <<= '192.168.1.0/24'::inet) as matching_records,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_network_ip_spgist') as spgist_scans,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_network_ip_btree') as btree_scans;

-- Анализ эффективности для разных алгоритмов разбиения пространства
SELECT 
    'Quad-tree (Points)' as algorithm,
    (SELECT pg_relation_size('idx_spatial_coordinates_spgist')) as index_size,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_spatial_coordinates_spgist') as scans;

SELECT 
    'k-d Tree (Multidimensional)' as algorithm,
    (SELECT pg_relation_size('idx_multidimensional_point_spgist')) as index_size,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_multidimensional_point_spgist') as scans;

SELECT 
    'Prefix Tree (Text)' as algorithm,
    (SELECT pg_relation_size('idx_text_word_spgist')) as index_size,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_text_word_spgist') as scans;

SELECT 
    'Radix Tree (Network)' as algorithm,
    (SELECT pg_relation_size('idx_network_ip_spgist')) as index_size,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_network_ip_spgist') as scans;

-- Рекомендации по использованию SP-GiST
SELECT 
    tablename,
    indexname,
    idx_scan as scans,
    pg_size_pretty(pg_relation_size(indexrelid)) as size,
    CASE 
        WHEN idx_scan = 0 THEN 'UNUSED - Consider if needed for specific queries'
        WHEN idx_scan < 5 THEN 'RARELY USED - Evaluate query patterns'
        WHEN pg_relation_size(indexrelid) > pg_relation_size(indrelid) * 0.3 THEN 'LARGE - Monitor performance'
        ELSE 'WELL UTILIZED'
    END as recommendation,
    CASE 
        WHEN indexname LIKE '%spgist%' THEN
            CASE 
                WHEN tablename = 'text_data' THEN 'Good for prefix searches (LIKE operator)'
                WHEN tablename = 'network_data' THEN 'Good for IP range queries'
                WHEN tablename = 'spatial_data' THEN 'Good for spatial queries and nearest neighbor'
                WHEN tablename = 'multidimensional_data' THEN 'Good for multidimensional range queries'
                WHEN tablename = 'bounding_boxes' THEN 'Good for bounding box overlaps'
                ELSE 'General SP-GiST usage'
            END
        ELSE 'B-tree comparison index'
    END as usage_note
FROM pg_stat_user_indexes 
JOIN pg_class ON pg_class.oid = indexrelid
WHERE schemaname = 'spgist'
ORDER BY idx_scan DESC;