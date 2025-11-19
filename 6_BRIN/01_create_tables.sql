-- Создание таблиц для демонстрации BRIN индекса
-- BRIN (Block Range Index) оптимален для больших таблиц с естественной сортировкой

DROP SCHEMA IF EXISTS BRIN CASCADE;
CREATE SCHEMA BRIN;

SET search_path TO BRIN;

-- Таблица временных рядов (логи с временными метками)
CREATE TABLE time_series_data (
    id BIGSERIAL PRIMARY KEY,
    sensor_id INTEGER NOT NULL,
    measurement_time TIMESTAMP NOT NULL,
    value NUMERIC(10,4) NOT NULL,
    sensor_type VARCHAR(50) NOT NULL,
    quality_flag BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица логов доступа с последовательными ID
CREATE TABLE access_logs (
    log_id BIGSERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    access_time TIMESTAMP NOT NULL,
    resource_path VARCHAR(500) NOT NULL,
    http_method VARCHAR(10) NOT NULL,
    status_code INTEGER NOT NULL,
    response_time_ms INTEGER,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица финансовых транзакций с датами
CREATE TABLE financial_transactions (
    transaction_id BIGSERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL,
    transaction_date DATE NOT NULL,
    amount NUMERIC(15,2) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    merchant_name VARCHAR(200),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица метрик системы с последовательными значениями
CREATE TABLE system_metrics (
    metric_id BIGSERIAL PRIMARY KEY,
    server_id INTEGER NOT NULL,
    metric_time TIMESTAMP NOT NULL,
    cpu_usage NUMERIC(5,2) NOT NULL,
    memory_usage NUMERIC(5,2) NOT NULL,
    disk_usage NUMERIC(5,2) NOT NULL,
    network_rx_mbps NUMERIC(10,2) NOT NULL,
    network_tx_mbps NUMERIC(10,2) NOT NULL,
    active_connections INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица географических данных с последовательными координатами
CREATE TABLE geographic_data (
    location_id BIGSERIAL PRIMARY KEY,
    latitude NUMERIC(10,6) NOT NULL,
    longitude NUMERIC(10,6) NOT NULL,
    elevation INTEGER NOT NULL,
    location_type VARCHAR(50) NOT NULL,
    recorded_date DATE NOT NULL,
    temperature NUMERIC(5,2),
    humidity NUMERIC(5,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Комментарии о структуре таблиц
COMMENT ON TABLE time_series_data IS 'Таблица временных рядов для тестирования BRIN с временными метками';
COMMENT ON TABLE access_logs IS 'Таблица логов доступа с последовательными ID и временем';
COMMENT ON TABLE financial_transactions IS 'Таблица финансовых транзакций с датами';
COMMENT ON TABLE system_metrics IS 'Таблица метрик системы с последовательными измерениями';
COMMENT ON TABLE geographic_data IS 'Таблица географических данных с последовательными координатами';

-- Создаем расширение для bloom индекса (если понадобится позже)
-- CREATE EXTENSION IF NOT EXISTS bloom;