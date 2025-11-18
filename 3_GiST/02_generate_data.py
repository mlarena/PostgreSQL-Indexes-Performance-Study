#!/usr/bin/env python3
"""
Генератор тестовых данных для GiST индекса
Генерирует данные для полнотекстового поиска, диапазонов и сетевых адресов
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

def generate_documents_data(num_records):
    """Генерация документов для полнотекстового поиска"""
    fake = Faker()
    documents = []
    tags_pool = ['technology', 'science', 'health', 'education', 'business', 
                 'entertainment', 'sports', 'politics', 'travel', 'food']
    
    # Определяем диапазон дат
    end_date = datetime.now()
    start_date_5y = end_date - timedelta(days=5*365)
    
    for i in range(num_records):
        # Генерируем контент разной длины
        content_paragraphs = []
        for _ in range(random.randint(3, 8)):
            content_paragraphs.append(fake.paragraph())
        
        content = '\n\n'.join(content_paragraphs)
        
        # Выбираем случайные теги (2-5 штук)
        num_tags = random.randint(2, 5)
        tags = random.sample(tags_pool, num_tags)
        
        document = (
            fake.sentence()[:200],  # title
            content,  # content
            fake.name(),  # author
            fake.date_between(start_date=start_date_5y, end_date=end_date),  # publication_date
            tags  # tags array
        )
        documents.append(document)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} документов")
    
    return documents

def generate_events_data(num_records):
    """Генерация событий с временными диапазонами"""
    fake = Faker()
    events = []
    event_types = ['conference', 'meeting', 'workshop', 'seminar', 'exhibition', 
                   'concert', 'festival', 'sports_event', 'webinar', 'training']
    cities = ['Moscow', 'Saint Petersburg', 'Novosibirsk', 'Yekaterinburg', 'Kazan']
    
    # Диапазон дат для событий
    end_date = datetime.now()
    start_date_1y = end_date - timedelta(days=365)
    future_date_1y = end_date + timedelta(days=365)
    
    for i in range(num_records):
        start_date = fake.date_time_between(start_date=start_date_1y, end_date=future_date_1y)
        duration_hours = random.randint(1, 72)  # от 1 часа до 3 дней
        end_date_event = start_date + timedelta(hours=duration_hours)
        
        event = (
            f"{random.choice(event_types)}: {fake.catch_phrase()}"[:100],
            f'[{start_date.isoformat()}, {end_date_event.isoformat()}]',  # TSRANGE
            random.choice(cities),
            random.randint(10, 1000),
            fake.text()[:500]
        )
        events.append(event)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} событий")
    
    return events

def generate_network_devices_data(num_records):
    """Генерация данных сетевых устройств"""
    fake = Faker()
    devices = []
    statuses = ['active', 'inactive', 'maintenance', 'offline']
    
    # Базовые сети для генерации IP
    base_networks = [
        '192.168.1.0/24',
        '10.0.0.0/16', 
        '172.16.0.0/20',
        '192.168.100.0/24',
        '10.10.0.0/16'
    ]
    
    for i in range(num_records):
        base_network = random.choice(base_networks)
        ip_parts = base_network.split('.')
        ip_suffix = random.randint(1, 254)
        
        if base_network.startswith('192.168'):
            ip_range = f"{ip_parts[0]}.{ip_parts[1]}.{ip_parts[2].split('/')[0]}.{ip_suffix}"
        else:
            ip_range = f"{ip_parts[0]}.{ip_parts[1]}.{random.randint(0, 255)}.{ip_suffix}"
        
        device = (
            f"{fake.word().capitalize()}-{fake.word().capitalize()}-{random.randint(1000, 9999)}",
            ip_range,
            fake.mac_address(),
            fake.city(),
            random.choice(statuses)
        )
        devices.append(device)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} сетевых устройств")
    
    return devices

def generate_simple_locations_data(num_records):
    """Генерация простых геоданных (без PostGIS)"""
    fake = Faker()
    locations = []
    categories = ['restaurant', 'hotel', 'museum', 'park', 'shop', 'hospital', 'school', 'office']
    cities = ['Moscow', 'Saint Petersburg', 'Novosibirsk', 'Yekaterinburg', 'Kazan']
    
    # Простые координаты для городов
    city_coordinates = {
        'Moscow': (55.7558, 37.6173),
        'Saint Petersburg': (59.9343, 30.3351),
        'Novosibirsk': (55.0084, 82.9357),
        'Yekaterinburg': (56.8389, 60.6057),
        'Kazan': (55.7963, 49.1089)
    }
    
    for i in range(num_records):
        city = random.choice(cities)
        base_x, base_y = city_coordinates[city]
        
        # Добавляем случайное смещение для разнообразия
        x = base_x + random.uniform(-0.5, 0.5)
        y = base_y + random.uniform(-0.5, 0.5)
        
        location = (
            fake.company()[:100],
            x,  # x_coord
            y,  # y_coord
            fake.address(),
            city,
            random.choice(categories)
        )
        locations.append(location)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} простых локаций")
    
    return locations

def main():
    config = DB_CONFIG.copy()
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Устанавливаем схему
        cursor.execute("SET search_path TO GiST")
        
        print("Генерация данных для GiST индексов...")
        
        # Генерация документов (ОСНОВНОЙ ТЕСТ)
        print("Генерация 40,000 документов...")
        documents_data = generate_documents_data(40000)
        
        print("Вставка документов в БД...")
        documents_sql = """
            INSERT INTO documents (title, content, author, publication_date, tags) 
            VALUES (%s, %s, %s, %s, %s)
        """
        
        batch_size = 1000
        for i in range(0, len(documents_data), batch_size):
            batch = documents_data[i:i + batch_size]
            cursor.executemany(documents_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} документов")
        
        # Генерация событий
        print("Генерация 25,000 событий...")
        events_data = generate_events_data(25000)
        
        print("Вставка событий в БД...")
        events_sql = """
            INSERT INTO events (event_name, event_period, location, max_participants, description) 
            VALUES (%s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(events_data), batch_size):
            batch = events_data[i:i + batch_size]
            cursor.executemany(events_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} событий")
        
        # Генерация сетевых устройств
        print("Генерация 20,000 сетевых устройств...")
        devices_data = generate_network_devices_data(20000)
        
        print("Вставка сетевых устройств в БД...")
        devices_sql = """
            INSERT INTO network_devices (device_name, ip_range, mac_address, location, status) 
            VALUES (%s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(devices_data), batch_size):
            batch = devices_data[i:i + batch_size]
            cursor.executemany(devices_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} сетевых устройств")
        
        # Генерация простых локаций
        print("Генерация 15,000 простых локаций...")
        locations_data = generate_simple_locations_data(15000)
        
        print("Вставка простых локаций в БД...")
        locations_sql = """
            INSERT INTO simple_locations (name, x_coord, y_coord, address, city, category) 
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(locations_data), batch_size):
            batch = locations_data[i:i + batch_size]
            cursor.executemany(locations_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} простых локаций")
        
        # Обновляем search_vector для полнотекстового поиска
        print("Обновление search_vector для полнотекстового поиска...")
        cursor.execute("""
            UPDATE documents 
            SET search_vector = to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''))
            WHERE search_vector IS NULL
        """)
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