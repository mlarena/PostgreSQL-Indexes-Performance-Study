#!/usr/bin/env python3
"""
Генератор тестовых данных для Bloom индекса
Генерирует данные для тестирования многоколоночной фильтрации
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

def generate_users_data(num_records):
    """Генерация данных пользователей"""
    fake = Faker()
    users = []
    
    countries = ['US', 'RU', 'DE', 'FR', 'CN', 'JP', 'BR', 'IN', 'GB', 'CA']
    registration_sources = ['web', 'mobile', 'social', 'referral', 'organic']
    
    used_usernames = set()
    used_emails = set()
    
    # Определяем диапазон дат
    end_date = datetime.now()
    start_date_1y = end_date - timedelta(days=365)
    
    for i in range(num_records):
        # Генерируем уникальные username и email
        while True:
            username = fake.user_name()[:50]
            if username not in used_usernames:
                used_usernames.add(username)
                break
        
        while True:
            email = fake.email()[:100]
            if email not in used_emails:
                used_emails.add(email)
                break
        
        record = (
            username,
            email,
            fake.phone_number()[:20],
            fake.first_name(),
            fake.last_name(),
            fake.date_of_birth(minimum_age=18, maximum_age=80),
            random.choice(countries),
            fake.city(),
            random.choice(registration_sources),
            fake.date_time_between(start_date=start_date_1y, end_date=end_date)
        )
        users.append(record)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} пользователей")
    
    return users

def generate_products_data(num_records):
    """Генерация данных продуктов"""
    fake = Faker()
    products = []
    
    categories = {
        'electronics': ['smartphones', 'laptops', 'tablets', 'headphones', 'cameras'],
        'clothing': ['men', 'women', 'kids', 'accessories'],
        'home': ['furniture', 'kitchen', 'bedding', 'decor'],
        'sports': ['fitness', 'outdoor', 'team sports', 'water sports'],
        'books': ['fiction', 'non-fiction', 'educational', 'children']
    }
    
    brands = {
        'electronics': ['Samsung', 'Apple', 'Sony', 'LG', 'Xiaomi', 'Huawei'],
        'clothing': ['Nike', 'Adidas', 'Zara', 'H&M', 'Uniqlo', 'Levi\'s'],
        'home': ['IKEA', 'Williams-Sonoma', 'Crate&Barrel', 'Pottery Barn'],
        'sports': ['Nike', 'Adidas', 'Under Armour', 'Puma', 'Reebok'],
        'books': ['Penguin', 'HarperCollins', 'Random House', 'Simon & Schuster']
    }
    
    colors = ['black', 'white', 'red', 'blue', 'green', 'yellow', 'purple', 'pink', 'gray', 'brown']
    sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL']
    
    for i in range(num_records):
        category = random.choice(list(categories.keys()))
        subcategory = random.choice(categories[category])
        brand = random.choice(brands[category])
        
        record = (
            f"PROD{random.randint(100000, 999999)}",
            fake.catch_phrase()[:200],
            brand,
            category,
            subcategory,
            random.randint(1, 100),
            fake.company(),
            random.choice(colors),
            random.choice(sizes) if category == 'clothing' else None,
            round(random.uniform(0.1, 50.0), 3),
            round(random.uniform(10, 2000), 2),
            random.choice([True, False])
        )
        products.append(record)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} продуктов")
    
    return products

def generate_orders_data(num_records, max_customer_id):
    """Генерация данных заказов"""
    fake = Faker()
    orders = []
    
    order_statuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled', 'returned']
    payment_methods = ['credit_card', 'debit_card', 'paypal', 'bank_transfer', 'cash']
    shipping_methods = ['standard', 'express', 'overnight', 'pickup']
    
    used_order_numbers = set()
    
    # Диапазон дат для заказов
    end_date = datetime.now()
    start_date_2y = end_date - timedelta(days=2*365)
    
    for i in range(num_records):
        # Генерируем уникальный номер заказа
        while True:
            order_number = f"ORD{random.randint(100000, 999999)}"
            if order_number not in used_order_numbers:
                used_order_numbers.add(order_number)
                break
        
        order_date = fake.date_between(start_date=start_date_2y, end_date=end_date)
        
        record = (
            order_number,
            random.randint(1, max_customer_id),
            random.choice(order_statuses),
            random.choice(payment_methods),
            random.choice(shipping_methods),
            random.randint(1, 10),
            random.randint(1, 50),
            round(random.uniform(20, 5000), 2),
            round(random.uniform(0, 500), 2),
            order_date,
            order_date + timedelta(days=random.randint(1, 14)) if random.random() > 0.2 else None
        )
        orders.append(record)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} заказов")
    
    return orders

def generate_security_logs(num_records, max_user_id):
    """Генерация логов безопасности"""
    fake = Faker()
    security_logs = []
    
    event_types = ['login', 'logout', 'password_change', 'profile_update', 'failed_login', 
                   'suspicious_activity', 'permission_change', 'data_access']
    device_types = ['desktop', 'mobile', 'tablet']
    browsers = ['Chrome', 'Firefox', 'Safari', 'Edge', 'Opera']
    operating_systems = ['Windows', 'macOS', 'Linux', 'iOS', 'Android']
    countries = ['United States', 'Russia', 'Germany', 'France', 'China', 'Japan', 'Brazil', 'India']
    
    # Диапазон дат для логов
    end_date = datetime.now()
    start_date_1y = end_date - timedelta(days=365)
    
    for i in range(num_records):
        record = (
            random.choice(event_types),
            random.randint(1, max_user_id) if random.random() > 0.1 else None,
            fake.ipv4(),
            fake.user_agent(),
            random.choice(device_types),
            random.choice(browsers),
            random.choice(operating_systems),
            random.choice(countries),
            fake.city(),
            random.choice([True, False]),
            fake.text()[:500]
        )
        security_logs.append(record)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} логов безопасности")
    
    return security_logs

def generate_inventory_data(num_records, max_product_id):
    """Генерация данных инвентаря"""
    fake = Faker()
    inventory = []
    
    location_codes = ['A', 'B', 'C', 'D', 'E', 'F']
    bin_numbers = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10']
    
    used_skus = set()
    
    # Диапазон дат для инвентаря
    end_date = datetime.now()
    start_date_future = end_date + timedelta(days=365)
    
    for i in range(num_records):
        # Генерируем уникальный SKU
        while True:
            sku = f"SKU{random.randint(10000, 99999)}"
            if sku not in used_skus:
                used_skus.add(sku)
                break
        
        record = (
            sku,
            random.randint(1, max_product_id),
            random.randint(1, 10),
            f"{random.choice(location_codes)}{random.randint(1, 20)}",
            random.choice(bin_numbers),
            random.randint(0, 1000),
            random.randint(0, 100),
            random.randint(10, 100),
            f"BATCH{random.randint(1000, 9999)}",
            fake.date_between(start_date=end_date, end_date=start_date_future) if random.random() > 0.7 else None,
            f"SUP{random.randint(100, 999)}"
        )
        inventory.append(record)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} записей инвентаря")
    
    return inventory

def main():
    config = DB_CONFIG.copy()
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Устанавливаем схему
        cursor.execute("SET search_path TO Bloom")
        
        print("Генерация данных для Bloom индексов...")
        
        # Генерация пользователей
        print("Генерация 100,000 пользователей...")
        users_data = generate_users_data(100000)
        
        print("Вставка пользователей в БД...")
        users_sql = """
            INSERT INTO users (username, email, phone, first_name, last_name, date_of_birth, country_code, city, registration_source, last_login) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        batch_size = 1000
        success_count = 0
        for i in range(0, len(users_data), batch_size):
            batch = users_data[i:i + batch_size]
            try:
                cursor.executemany(users_sql, batch)
                conn.commit()
                success_count += len(batch)
                print(f"Вставлено {success_count} пользователей")
            except Exception as e:
                conn.rollback()
                print(f"Ошибка в пакете, вставляем по одному...")
                for record in batch:
                    try:
                        cursor.execute(users_sql, record)
                        conn.commit()
                        success_count += 1
                    except:
                        conn.rollback()
                        continue
                print(f"Вставлено {success_count} пользователей")
        
        # Генерация продуктов
        print("Генерация 80,000 продуктов...")
        products_data = generate_products_data(80000)
        
        print("Вставка продуктов в БД...")
        products_sql = """
            INSERT INTO products (product_code, name, brand, category, subcategory, supplier_id, manufacturer, color, size, weight_kg, price, in_stock) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(products_data), batch_size):
            batch = products_data[i:i + batch_size]
            cursor.executemany(products_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} продуктов")
        
        # Генерация заказов
        print("Генерация 150,000 заказов...")
        orders_data = generate_orders_data(150000, 100000)
        
        print("Вставка заказов в БД...")
        orders_sql = """
            INSERT INTO orders (order_number, customer_id, order_status, payment_method, shipping_method, warehouse_id, sales_rep_id, total_amount, discount_amount, order_date, delivery_date) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(orders_data), batch_size):
            batch = orders_data[i:i + batch_size]
            cursor.executemany(orders_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} заказов")
        
        # Генерация логов безопасности
        print("Генерация 200,000 логов безопасности...")
        security_logs_data = generate_security_logs(200000, 100000)
        
        print("Вставка логов безопасности в БД...")
        security_sql = """
            INSERT INTO security_logs (event_type, user_id, ip_address, user_agent, device_type, browser, os, country, city, success, details) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(security_logs_data), batch_size):
            batch = security_logs_data[i:i + batch_size]
            cursor.executemany(security_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} логов безопасности")
        
        # Генерация данных инвентаря (уменьшаем до 80,000 чтобы избежать проблем с уникальностью)
        print("Генерация 80,000 записей инвентаря...")
        inventory_data = generate_inventory_data(80000, 80000)
        
        print("Вставка инвентаря в БД...")
        inventory_sql = """
            INSERT INTO inventory (sku, product_id, warehouse_id, location_code, bin_number, quantity, reserved_quantity, reorder_level, batch_number, expiry_date, supplier_batch) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(inventory_data), batch_size):
            batch = inventory_data[i:i + batch_size]
            cursor.executemany(inventory_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} записей инвентаря")
        
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