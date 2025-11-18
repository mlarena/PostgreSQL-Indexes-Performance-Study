"""
Генератор тестовых данных для B-tree индекса
Генерирует пользователей и заказы для тестирования диапазонных запросов
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
    
    for i in range(num_records):
        user = (
            fake.user_name()[:50],
            fake.email()[:100],
            random.randint(18, 80),  # возраст
            round(random.uniform(30000, 150000), 2),  # зарплата
            fake.date_between(start_date='-5 years', end_date='today'),  # дата создания
            fake.date_time_between(start_date='-1 year', end_date='now'),  # последний вход
            random.choice([True, False])  # активность
        )
        users.append(user)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} пользователей")
    
    return users

def generate_orders_data(num_records, max_user_id):
    """Генерация данных заказов"""
    fake = Faker()
    orders = []
    statuses = ['pending', 'completed', 'shipped', 'cancelled']
    categories = ['electronics', 'books', 'clothing', 'home', 'sports']
    
    for i in range(num_records):
        order = (
            random.randint(1, max_user_id),  # user_id
            fake.date_between(start_date='-2 years', end_date='today'),  # order_date
            round(random.uniform(10, 1000), 2),  # amount
            random.choice(statuses),  # status
            random.choice(categories)  # product_category
        )
        orders.append(order)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} заказов")
    
    return orders

def main():
    config = DB_CONFIG.copy()
    config['search_path'] = 'Btree'
    
    conn = get_db_connection()
    conn.autocommit = False
    cursor = conn.cursor()
    
    try:
        print("Генерация данных для B-tree индексов...")
        
        # Генерация пользователей
        print("Генерация 500,000 пользователей...")
        users_data = generate_users_data(500000)
        
        print("Вставка пользователей в БД...")
        users_sql = """
            INSERT INTO users (username, email, age, salary, created_date, last_login, is_active) 
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        
        batch_size = 1000
        for i in range(0, len(users_data), batch_size):
            batch = users_data[i:i + batch_size]
            cursor.executemany(users_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} пользователей")
        
        # Генерация заказов
        print("Генерация 1,000,000 заказов...")
        orders_data = generate_orders_data(1000000, 500000)
        
        print("Вставка заказов в БД...")
        orders_sql = """
            INSERT INTO orders (user_id, order_date, amount, status, product_category) 
            VALUES (%s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(orders_data), batch_size):
            batch = orders_data[i:i + batch_size]
            cursor.executemany(orders_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} заказов")
        
        print("Данные успешно сгенерированы!")
        
    except Exception as e:
        conn.rollback()
        print(f"Ошибка: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    main()