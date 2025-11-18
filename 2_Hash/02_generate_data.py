#!/usr/bin/env python3
"""
Генератор тестовых данных для Hash индекса
Генерирует данные для тестирования точечного поиска по равенству
"""

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'shared'))

import psycopg2
from faker import Faker
import random
import hashlib
from datetime import datetime, timedelta
from database_config import DB_CONFIG
from utils import get_db_connection

def generate_products_data(num_records):
    """Генерация данных продуктов"""
    fake = Faker()
    products = []
    categories = ['electronics', 'books', 'clothing', 'home', 'sports', 'beauty', 'toys', 'food']
    
    # Создаем набор уникальных кодов продуктов
    product_codes = set()
    while len(product_codes) < num_records:
        product_codes.add(f"PROD{random.randint(100000, 999999)}")
    
    product_codes = list(product_codes)
    
    for i in range(num_records):
        product = (
            product_codes[i],
            fake.company()[:100],
            random.choice(categories),
            round(random.uniform(1, 1000), 2),
            random.randint(1, 1000),  # supplier_id
            random.choice([True, False])  # in_stock
        )
        products.append(product)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} продуктов")
    
    return products

def generate_sessions_data(num_records, max_user_id):
    """Генерация данных сессий"""
    fake = Faker()
    sessions = []
    
    # Диапазоны дат
    end_date = datetime.now()
    start_date_30d = end_date - timedelta(days=30)
    future_date_30d = end_date + timedelta(days=30)
    
    for i in range(num_records):
        session_id = hashlib.sha256(f"{i}{fake.uuid4()}".encode()).hexdigest()
        session = (
            session_id,
            random.randint(1, max_user_id),
            fake.date_time_between(start_date=start_date_30d, end_date=end_date),
            fake.date_time_between(start_date=end_date, end_date=future_date_30d),
            fake.ipv4(),
            fake.user_agent(),
            random.choice([True, False])
        )
        sessions.append(session)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} сессий")
    
    return sessions

def generate_config_data():
    """Генерация конфигурационных данных"""
    configs = [
        ('app.name', 'My Application'),
        ('app.version', '1.0.0'),
        ('database.host', 'localhost'),
        ('database.port', '5432'),
        ('cache.enabled', 'true'),
        ('cache.ttl', '3600'),
        ('email.smtp_host', 'smtp.example.com'),
        ('email.smtp_port', '587'),
        ('logging.level', 'INFO'),
        ('security.encryption_key', 'secret-key-123'),
        ('ui.theme', 'dark'),
        ('ui.language', 'en'),
        ('payment.currency', 'USD'),
        ('payment.provider', 'stripe'),
        ('analytics.enabled', 'true')
    ]
    return configs

def main():
    config = DB_CONFIG.copy()
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Устанавливаем схему
        cursor.execute("SET search_path TO Hash")
        
        print("Генерация данных для Hash индексов...")
        
        # Генерация продуктов
        print("Генерация 50,000 продуктов...")
        products_data = generate_products_data(50000)
        
        print("Вставка продуктов в БД...")
        products_sql = """
            INSERT INTO products (product_code, name, category, price, supplier_id, in_stock) 
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        
        batch_size = 1000
        for i in range(0, len(products_data), batch_size):
            batch = products_data[i:i + batch_size]
            cursor.executemany(products_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} продуктов")
        
        # Генерация сессий
        print("Генерация 100,000 сессий...")
        sessions_data = generate_sessions_data(100000, 50000)
        
        print("Вставка сессий в БД...")
        sessions_sql = """
            INSERT INTO user_sessions (session_id, user_id, created_at, expires_at, ip_address, user_agent, is_valid) 
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(sessions_data), batch_size):
            batch = sessions_data[i:i + batch_size]
            cursor.executemany(sessions_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} сессий")
        
        # Вставка конфигурации
        print("Вставка конфигурационных данных...")
        config_data = generate_config_data()
        config_sql = "INSERT INTO config (config_key, config_value) VALUES (%s, %s)"
        cursor.executemany(config_sql, config_data)
        conn.commit()
        
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