-- Создание BRIN индексов
SET search_path TO BRIN;

-- Индекс 1: BRIN для временных меток временных рядов
CREATE INDEX CONCURRENTLY idx_time_series_measurement_time_brin ON time_series_data USING BRIN (measurement_time);

-- Индекс 2: BRIN для дат финансовых транзакций
CREATE INDEX CONCURRENTLY idx_transactions_date_brin ON financial_transactions USING BRIN (transaction_date);

-- Индекс 3: BRIN для времени доступа в логах
CREATE INDEX CONCURRENTLY idx_access_logs_time_brin ON access_logs USING BRIN (access_time);

-- Индекс 4: BRIN для времени метрик системы
CREATE INDEX CONCURRENTLY idx_metrics_time_brin ON system_metrics USING BRIN (metric_time);

-- Индекс 5: BRIN для координат географических данных
CREATE INDEX CONCURRENTLY idx_geo_latitude_brin ON geographic_data USING BRIN (latitude);
CREATE INDEX CONCURRENTLY idx_geo_longitude_brin ON geographic_data USING BRIN (longitude);

-- Индекс 6: BRIN для дат географических данных
CREATE INDEX CONCURRENTLY idx_geo_date_brin ON geographic_data USING BRIN (recorded_date);

-- Специализированные BRIN индексы с настройками

-- Индекс 7: BRIN с увеличенным pages_per_range для временных рядов
CREATE INDEX CONCURRENTLY idx_time_series_measurement_time_brin_large ON time_series_data USING BRIN (measurement_time) WITH (pages_per_range = 128);

-- Индекс 8: BRIN для суммы транзакций (если данные коррелируют с датой)
CREATE INDEX CONCURRENTLY idx_transactions_amount_brin ON financial_transactions USING BRIN (amount);

-- Индекс 9: BRIN для ID сенсоров (если данные вставлены последовательно)
CREATE INDEX CONCURRENTLY idx_time_series_sensor_id_brin ON time_series_data USING BRIN (sensor_id);

-- Индекс 10: BRIN для использования CPU
CREATE INDEX CONCURRENTLY idx_metrics_cpu_brin ON system_metrics USING BRIN (cpu_usage);

-- Для сравнения: B-tree индексы на тех же полях
CREATE INDEX CONCURRENTLY idx_time_series_measurement_time_btree ON time_series_data USING BTREE (measurement_time);
CREATE INDEX CONCURRENTLY idx_transactions_date_btree ON financial_transactions USING BTREE (transaction_date);
CREATE INDEX CONCURRENTLY idx_access_logs_time_btree ON access_logs USING BTREE (access_time);

-- Составные BRIN индексы
CREATE INDEX CONCURRENTLY idx_time_series_composite_brin ON time_series_data USING BRIN (measurement_time, sensor_id);

-- Анализ таблиц для обновления статистики
ANALYZE time_series_data;
ANALYZE access_logs;
ANALYZE financial_transactions;
ANALYZE system_metrics;
ANALYZE geographic_data;