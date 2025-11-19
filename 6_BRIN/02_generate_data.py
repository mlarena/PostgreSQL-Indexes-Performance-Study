#!/usr/bin/env python3
"""
Генератор тестовых данных для BRIN индекса
Генерирует большие объемы данных с естественной сортировкой
"""

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'shared'))

import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta
from database_config import DB_CONFIG
from utils import get_db_connection

def generate_time_series_data(num_records):
    """Генерация данных временных рядов"""
    fake = Faker()
    time_series = []
    
    sensor_types = ['temperature', 'pressure', 'humidity', 'voltage', 'current', 'rpm']
    sensor_ids = list(range(1, 101))  # 100 сенсоров
    
    # Начальная дата для временных рядов
    start_date = datetime.now() - timedelta(days=365)
    
    for i in range(num_records):
        sensor_id = random.choice(sensor_ids)
        
        # Создаем последовательные временные метки
        measurement_time = start_date + timedelta(
            days=random.randint(0, 364),
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )
        
        # Генерируем значения в зависимости от типа сенсора
        sensor_type = random.choice(sensor_types)
        if sensor_type == 'temperature':
            value = round(random.uniform(-20, 50), 4)
        elif sensor_type == 'pressure':
            value = round(random.uniform(950, 1050), 4)
        elif sensor_type == 'humidity':
            value = round(random.uniform(0, 100), 4)
        elif sensor_type == 'voltage':
            value = round(random.uniform(220, 240), 4)
        elif sensor_type == 'current':
            value = round(random.uniform(0, 100), 4)
        else:  # rpm
            value = round(random.uniform(0, 3000), 4)
        
        record = (
            sensor_id,
            measurement_time,
            value,
            sensor_type,
            random.choice([True, False])  # quality_flag
        )
        time_series.append(record)
        
        if i % 50000 == 0 and i > 0:
            print(f"Сгенерировано {i} записей временных рядов")
    
    return time_series

def generate_access_logs(num_records):
    """Генерация логов доступа"""
    fake = Faker()
    access_logs = []
    
    http_methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
    status_codes = [200, 201, 400, 401, 403, 404, 500]
    resource_paths = [
        '/api/users', '/api/products', '/api/orders', '/api/auth', 
        '/api/payments', '/api/reports', '/api/settings', '/api/health'
    ]
    
    # Начальная дата для логов
    start_date = datetime.now() - timedelta(days=180)
    
    for i in range(num_records):
        access_time = start_date + timedelta(
            days=random.randint(0, 179),
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )
        
        record = (
            random.randint(1, 10000),  # user_id
            access_time,
            f"{random.choice(resource_paths)}/{fake.uri_path()}",
            random.choice(http_methods),
            random.choice(status_codes),
            random.randint(10, 5000),  # response_time_ms
            fake.ipv4(),
            fake.user_agent()
        )
        access_logs.append(record)
        
        if i % 50000 == 0 and i > 0:
            print(f"Сгенерировано {i} логов доступа")
    
    return access_logs

def generate_financial_transactions(num_records):
    """Генерация финансовых транзакций"""
    fake = Faker()
    transactions = []
    
    transaction_types = ['debit', 'credit', 'transfer', 'payment', 'withdrawal']
    categories = ['food', 'transport', 'entertainment', 'utilities', 'shopping', 'healthcare']
    
    # Начальная дата для транзакций
    start_date = datetime.now() - timedelta(days=730)  # 2 года
    
    for i in range(num_records):
        transaction_date = (start_date + timedelta(days=random.randint(0, 729))).date()
        
        amount = round(random.uniform(1, 5000), 2)
        if random.choice(transaction_types) in ['debit', 'withdrawal']:
            amount = -amount  # Отрицательные суммы для расходов
        
        record = (
            random.randint(1, 5000),  # account_id
            transaction_date,
            amount,
            random.choice(transaction_types),
            fake.sentence(),
            random.choice(categories),
            fake.company()
        )
        transactions.append(record)
        
        if i % 50000 == 0 and i > 0:
            print(f"Сгенерировано {i} финансовых транзакций")
    
    return transactions

def generate_system_metrics(num_records):
    """Генерация метрик системы"""
    fake = Faker()
    metrics = []
    
    server_ids = list(range(1, 51))  # 50 серверов
    
    # Начальная дата для метрик
    start_date = datetime.now() - timedelta(days=30)
    
    for i in range(num_records):
        server_id = random.choice(server_ids)
        metric_time = start_date + timedelta(
            hours=random.randint(0, 719),  # 30 дней * 24 часа
            minutes=random.randint(0, 59)
        )
        
        record = (
            server_id,
            metric_time,
            round(random.uniform(0, 100), 2),  # cpu_usage
            round(random.uniform(0, 100), 2),  # memory_usage
            round(random.uniform(0, 100), 2),  # disk_usage
            round(random.uniform(0, 1000), 2),  # network_rx_mbps
            round(random.uniform(0, 500), 2),   # network_tx_mbps
            random.randint(0, 10000)  # active_connections
        )
        metrics.append(record)
        
        if i % 50000 == 0 and i > 0:
            print(f"Сгенерировано {i} метрик системы")
    
    return metrics

def generate_geographic_data(num_records):
    """Генерация географических данных"""
    fake = Faker()
    geographic_data = []
    
    location_types = ['weather_station', 'sensor_node', 'research_site', 'monitoring_point']
    
    # Базовые координаты для генерации последовательных данных
    base_latitudes = [55.7558, 59.9343, 54.9885, 56.8389, 55.7963]  # Москва, СПб, Омск, Екатеринбург, Казань
    base_longitudes = [37.6173, 30.3351, 73.3242, 60.6057, 49.1089]
    
    # Начальная дата
    start_date = datetime.now() - timedelta(days=365)
    
    for i in range(num_records):
        base_idx = i % len(base_latitudes)
        latitude = base_latitudes[base_idx] + random.uniform(-0.5, 0.5)
        longitude = base_longitudes[base_idx] + random.uniform(-0.5, 0.5)
        
        recorded_date = (start_date + timedelta(days=random.randint(0, 364))).date()
        
        record = (
            round(latitude, 6),
            round(longitude, 6),
            random.randint(-100, 3000),  # elevation
            random.choice(location_types),
            recorded_date,
            round(random.uniform(-30, 40), 2),  # temperature
            round(random.uniform(0, 100), 2)    # humidity
        )
        geographic_data.append(record)
        
        if i % 50000 == 0 and i > 0:
            print(f"Сгенерировано {i} географических записей")
    
    return geographic_data

def main():
    config = DB_CONFIG.copy()
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Устанавливаем схему
        cursor.execute("SET search_path TO BRIN")
        
        print("Генерация данных для BRIN индексов...")
        
        # Генерация временных рядов (большая таблица)
        print("Генерация 500,000 записей временных рядов...")
        time_series_data = generate_time_series_data(500000)
        
        print("Вставка временных рядов в БД...")
        time_series_sql = """
            INSERT INTO time_series_data (sensor_id, measurement_time, value, sensor_type, quality_flag) 
            VALUES (%s, %s, %s, %s, %s)
        """
        
        batch_size = 5000
        for i in range(0, len(time_series_data), batch_size):
            batch = time_series_data[i:i + batch_size]
            cursor.executemany(time_series_sql, batch)
            conn.commit()
            if (i // batch_size) % 10 == 0:  # Логируем каждые 10 пакетов
                print(f"Вставлено {i + len(batch)} записей временных рядов")
        
        print("Вставлено 500,000 записей временных рядов")
        
        # Генерация логов доступа
        print("Генерация 300,000 логов доступа...")
        access_logs_data = generate_access_logs(300000)
        
        print("Вставка логов доступа в БД...")
        access_logs_sql = """
            INSERT INTO access_logs (user_id, access_time, resource_path, http_method, status_code, response_time_ms, ip_address, user_agent) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(access_logs_data), batch_size):
            batch = access_logs_data[i:i + batch_size]
            cursor.executemany(access_logs_sql, batch)
            conn.commit()
            if (i // batch_size) % 10 == 0:
                print(f"Вставлено {i + len(batch)} логов доступа")
        
        print("Вставлено 300,000 логов доступа")
        
        # Генерация финансовых транзакций
        print("Генерация 400,000 финансовых транзакций...")
        transactions_data = generate_financial_transactions(400000)
        
        print("Вставка финансовых транзакций в БД...")
        transactions_sql = """
            INSERT INTO financial_transactions (account_id, transaction_date, amount, transaction_type, description, category, merchant_name) 
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(transactions_data), batch_size):
            batch = transactions_data[i:i + batch_size]
            cursor.executemany(transactions_sql, batch)
            conn.commit()
            if (i // batch_size) % 10 == 0:
                print(f"Вставлено {i + len(batch)} финансовых транзакций")
        
        print("Вставлено 400,000 финансовых транзакций")
        
        # Генерация метрик системы
        print("Генерация 200,000 метрик системы...")
        metrics_data = generate_system_metrics(200000)
        
        print("Вставка метрик системы в БД...")
        metrics_sql = """
            INSERT INTO system_metrics (server_id, metric_time, cpu_usage, memory_usage, disk_usage, network_rx_mbps, network_tx_mbps, active_connections) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(metrics_data), batch_size):
            batch = metrics_data[i:i + batch_size]
            cursor.executemany(metrics_sql, batch)
            conn.commit()
            if (i // batch_size) % 10 == 0:
                print(f"Вставлено {i + len(batch)} метрик системы")
        
        print("Вставлено 200,000 метрик системы")
        
        # Генерация географических данных
        print("Генерация 150,000 географических записей...")
        geographic_data = generate_geographic_data(150000)
        
        print("Вставка географических данных в БД...")
        geographic_sql = """
            INSERT INTO geographic_data (latitude, longitude, elevation, location_type, recorded_date, temperature, humidity) 
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(geographic_data), batch_size):
            batch = geographic_data[i:i + batch_size]
            cursor.executemany(geographic_sql, batch)
            conn.commit()
            if (i // batch_size) % 10 == 0:
                print(f"Вставлено {i + len(batch)} географических записей")
        
        print("Вставлено 150,000 географических записей")
        
        print("Данные успешно сгенерированы!")
        
    except Exception as e:
        conn.rollback()
        print(f"Ошибка: {e}")
        import traceback
        traceback.print_exc()
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    main()