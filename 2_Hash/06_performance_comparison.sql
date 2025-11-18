-- Сравнение производительности Hash и B-tree индексов
SET search_path TO Hash;

-- Размеры индексов
SELECT 
    indexname,
    indexdef,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes 
WHERE schemaname = 'hash'
ORDER BY pg_relation_size(indexname::regclass) DESC;

-- Статистика использования индексов
SELECT 
    indexrelname as index_name,
    idx_scan as scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes 
WHERE schemaname = 'hash'
ORDER BY idx_scan DESC;

-- Сравнение времени выполнения запросов (нужно запустить до и после)
-- Эта информация собирается из EXPLAIN ANALYZE

-- Эффективность Hash vs B-tree для точечного поиска
SELECT 
    'Hash Index' as index_type,
    (SELECT pg_relation_size('idx_products_code_hash')) as size_bytes,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_products_code_hash') as scans;

SELECT 
    'B-tree Index' as index_type, 
    (SELECT pg_relation_size('idx_products_code_btree')) as size_bytes,
    (SELECT idx_scan FROM pg_stat_user_indexes WHERE indexrelname = 'idx_products_code_btree') as scans;