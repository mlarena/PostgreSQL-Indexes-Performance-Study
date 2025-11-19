-- Сравнение производительности Bloom индексов
SET search_path TO Bloom;

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
WHERE schemaname = 'bloom'
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
WHERE schemaname = 'bloom'
ORDER BY idx_scan DESC;

-- Сравнение Bloom и B-tree для разных типов запросов
WITH index_stats AS (
    SELECT 
        indexrelname,
        idx_scan,
        idx_tup_read,
        idx_tup_fetch,
        pg_relation_size(indexrelid) as index_size_bytes
    FROM pg_stat_user_indexes 
    WHERE schemaname = 'bloom'
)
SELECT 
    CASE 
        WHEN indexrelname LIKE '%bloom%' THEN 'Bloom'
        WHEN indexrelname LIKE '%btree%' THEN 'B-tree'
        ELSE 'Other'
    END as index_type,
    CASE 
        WHEN indexrelname LIKE '%users%' THEN 'Multi-column User Search'
        WHEN indexrelname LIKE '%products%' THEN 'Product Attribute Filtering'
        WHEN indexrelname LIKE '%orders%' THEN 'Order Status & Methods'
        WHEN indexrelname LIKE '%security%' THEN 'Security Log Analysis'
        WHEN indexrelname LIKE '%inventory%' THEN 'Inventory Management'
        ELSE 'Other Use Case'
    END as use_case,
    COUNT(*) as index_count,
    SUM(idx_scan) as total_scans,
    pg_size_pretty(SUM(index_size_bytes)) as total_size,
    CASE 
        WHEN SUM(idx_scan) > 0 THEN 
            round(SUM(index_size_bytes)::numeric / SUM(idx_scan) / 1024, 2)
        ELSE 0 
    END as avg_kb_per_scan
FROM index_stats
GROUP BY index_type, use_case
ORDER BY use_case, index_type;

-- Эффективность для конкретных use cases
SELECT 
    'Multi-criteria User Search' as use_case,
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM users WHERE username LIKE 'john%' OR email LIKE '%gmail.com' OR country_code = 'US') as matching_users,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_users_bloom') as bloom_scans,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_users_username_btree') as btree_scans;

SELECT 
    'Product Attribute Filtering' as use_case,
    (SELECT COUNT(*) FROM products) as total_products,
    (SELECT COUNT(*) FROM products WHERE brand = 'Samsung' OR category = 'electronics' OR price BETWEEN 100 AND 500) as matching_products,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_products_bloom') as bloom_scans,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_products_brand_btree') as btree_scans;

-- Сравнение размера Bloom и B-tree индексов
SELECT 
    'Bloom Indexes' as index_type,
    COUNT(*) as total_indexes,
    SUM(pg_relation_size(indexname::regclass)) as total_size_bytes,
    pg_size_pretty(SUM(pg_relation_size(indexname::regclass))) as total_size,
    (SELECT SUM(idx_scan) FROM pg_stat_user_indexes WHERE schemaname = 'bloom' AND indexrelname LIKE '%bloom%') as total_scans
FROM pg_indexes 
WHERE schemaname = 'bloom' AND indexname LIKE '%bloom%'

UNION ALL

SELECT 
    'B-tree Indexes' as index_type,
    COUNT(*) as total_indexes,
    SUM(pg_relation_size(indexname::regclass)) as total_size_bytes,
    pg_size_pretty(SUM(pg_relation_size(indexname::regclass))) as total_size,
    (SELECT SUM(idx_scan) FROM pg_stat_user_indexes WHERE schemaname = 'bloom' AND indexrelname LIKE '%btree%') as total_scans
FROM pg_indexes 
WHERE schemaname = 'bloom' AND indexname LIKE '%btree%';

-- Анализ эффективности Bloom для разных типов данных
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
WHERE schemaname = 'bloom' AND idx_scan > 0;

-- Рекомендации по использованию Bloom
SELECT 
    tablename,
    indexname,
    idx_scan as scans,
    pg_size_pretty(pg_relation_size(indexrelid)) as size,
    CASE 
        WHEN idx_scan = 0 THEN 'UNUSED - Consider for multi-column OR queries'
        WHEN idx_scan < 5 THEN 'RARELY USED - Evaluate query patterns'
        WHEN pg_relation_size(indexrelid) > pg_relation_size(indrelid) * 0.2 THEN 'LARGE - Review column selection'
        ELSE 'WELL UTILIZED'
    END as recommendation,
    CASE 
        WHEN indexname LIKE '%bloom%' THEN
            CASE 
                WHEN tablename = 'users' THEN 'Ideal for user search across multiple attributes'
                WHEN tablename = 'products' THEN