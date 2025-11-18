#!/usr/bin/env python3
"""
Генератор тестовых данных для SP-GiST индекса
Генерирует данные для тестирования пространственного разбиения и нерегулярных структур
"""

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'shared'))

import psycopg2
from faker import Faker
import random
import json
from datetime import datetime, timedelta
from database_config import DB_CONFIG
from utils import get_db_connection

def generate_spatial_data(num_records):
    """Генерация пространственных данных (точки)"""
    fake = Faker()
    spatial_data = []
    object_types = ['building', 'tree', 'vehicle', 'person', 'sensor', 'landmark', 'station']
    
    # Генерируем точки в пределах заданной области
    min_x, max_x = 0, 1000  # X координаты
    min_y, max_y = 0, 1000  # Y координаты
    
    for i in range(num_records):
        x = random.uniform(min_x, max_x)
        y = random.uniform(min_y, max_y)
        
        record = (
            fake.word().capitalize() + ' ' + fake.word().capitalize(),
            f'({x},{y})',  # POINT format
            random.choice(object_types)
        )
        spatial_data.append(record)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} пространственных записей")
    
    return spatial_data

def generate_multidimensional_data(num_records):
    """Генерация многомерных данных"""
    fake = Faker()
    multidimensional_data = []
    categories = ['cluster_A', 'cluster_B', 'cluster_C', 'outlier', 'noise']
    
    # Создаем несколько кластеров для реалистичных данных
    clusters = [
        (200, 200, 50),   # центр (x,y) и радиус
        (700, 300, 80),
        (400, 600, 60),
        (800, 700, 40)
    ]
    
    for i in range(num_records):
        # 80% точек в кластерах, 20% случайных
        if random.random() < 0.8:
            cluster = random.choice(clusters)
            center_x, center_y, radius = cluster
            # Генерируем точку в пределах кластера (нормальное распределение)
            x = random.gauss(center_x, radius/3)
            y = random.gauss(center_y, radius/3)
            # Ограничиваем область
            x = max(0, min(1000, x))
            y = max(0, min(1000, y))
            category = f'cluster_{["A", "B", "C"][clusters.index(cluster) % 3]}'
        else:
            x = random.uniform(0, 1000)
            y = random.uniform(0, 1000)
            category = random.choice(['outlier', 'noise'])
        
        metadata = {
            'generated_at': datetime.now().isoformat(),
            'cluster_id': hash((x, y)) % 1000,
            'density': random.uniform(0.1, 1.0)
        }
        
        record = (
            f'({x},{y})',
            category,
            json.dumps(metadata)
        )
        multidimensional_data.append(record)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} многомерных записей")
    
    return multidimensional_data

def generate_text_data(num_records):
    """Генерация текстовых данных для префиксных деревьев"""
    fake = Faker()
    text_data = []
    languages = ['english', 'russian', 'german', 'french', 'spanish']
    parts_of_speech = ['noun', 'verb', 'adjective', 'adverb', 'preposition', 'conjunction']
    
    # Создаем базовый набор слов с разными префиксами
    base_words = []
    prefixes = ['auto', 'bio', 'tele', 'micro', 'macro', 'hyper', 'super', 'inter', 'trans', 'multi']
    suffixes = ['tion', 'ment', 'ness', 'ity', 'ance', 'ence', 'ship', 'hood']
    
    for prefix in prefixes:
        for suffix in suffixes:
            base_words.append(f"{prefix}{fake.word()}{suffix}")
    
    # Добавляем случайные слова
    for _ in range(1000):
        base_words.append(fake.word())
    
    base_words = list(set(base_words))  # Уникальные слова
    
    for i in range(num_records):
        word = random.choice(base_words)
        # Иногда добавляем префиксы для тестирования поиска по префиксам
        if random.random() < 0.3:
            word = random.choice(prefixes) + word
        
        record = (
            word[:100],
            random.choice(languages),
            random.randint(1, 10000),  # frequency
            random.choice(parts_of_speech)
        )
        text_data.append(record)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} текстовых записей")
    
    return text_data

def generate_network_data(num_records):
    """Генерация сетевых данных"""
    fake = Faker()
    network_data = []
    country_codes = ['US', 'RU', 'DE', 'FR', 'CN', 'JP', 'BR', 'IN', 'GB', 'CA']
    
    # Базовые сети для генерации
    base_networks = [
        '192.168.0.0/16',
        '10.0.0.0/8',
        '172.16.0.0/12',
        '203.0.113.0/24',
        '198.51.100.0/24'
    ]
    
    for i in range(num_records):
        base_network = random.choice(base_networks)
        
        if base_network.startswith('192.168'):
            # Для 192.168.0.0/16 генерируем случайный IP в диапазоне
            ip_parts = ['192', '168', str(random.randint(0, 255)), str(random.randint(1, 254))]
            ip_address = '.'.join(ip_parts)
            network_range = '192.168.0.0/16'
        elif base_network.startswith('10.'):
            ip_parts = ['10', str(random.randint(0, 255)), str(random.randint(0, 255)), str(random.randint(1, 254))]
            ip_address = '.'.join(ip_parts)
            network_range = '10.0.0.0/8'
        else:
            # Для других сетей используем Faker
            ip_address = fake.ipv4()
            network_range = base_network
        
        record = (
            ip_address,
            fake.hostname(),
            network_range,
            random.choice(country_codes)
        )
        network_data.append(record)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} сетевых записей")
    
    return network_data

def generate_bounding_boxes(num_records):
    """Генерация данных с ограничивающими прямоугольниками"""
    fake = Faker()
    bounding_boxes = []
    object_types = ['window', 'button', 'image', 'text', 'container', 'panel', 'dialog']
    
    for i in range(num_records):
        # Генерируем прямоугольник (x1, y1, x2, y2)
        x1 = random.uniform(0, 800)
        y1 = random.uniform(0, 600)
        width = random.uniform(10, 200)
        height = random.uniform(10, 150)
        x2 = x1 + width
        y2 = y1 + height
        
        record = (
            fake.word().capitalize() + ' ' + fake.word().capitalize(),
            f'({x1},{y1},{x2},{y2})',  # BOX format
            random.choice(object_types)
        )
        bounding_boxes.append(record)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} прямоугольников")
    
    return bounding_boxes

def main():
    config = DB_CONFIG.copy()
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Устанавливаем схему
        cursor.execute("SET search_path TO SPGiST")
        
        print("Генерация данных для SP-GiST индексов...")
        
        # Генерация пространственных данных
        print("Генерация 30,000 пространственных записей...")
        spatial_data = generate_spatial_data(30000)
        
        print("Вставка пространственных данных в БД...")
        spatial_sql = """
            INSERT INTO spatial_data (location_name, coordinates, object_type) 
            VALUES (%s, %s, %s)
        """
        
        batch_size = 1000
        for i in range(0, len(spatial_data), batch_size):
            batch = spatial_data[i:i + batch_size]
            cursor.executemany(spatial_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} пространственных записей")
        
        # Генерация многомерных данных
        print("Генерация 25,000 многомерных записей...")
        multidimensional_data = generate_multidimensional_data(25000)
        
        print("Вставка многомерных данных в БД...")
        multidimensional_sql = """
            INSERT INTO multidimensional_data (data_point, category, metadata) 
            VALUES (%s, %s, %s)
        """
        
        for i in range(0, len(multidimensional_data), batch_size):
            batch = multidimensional_data[i:i + batch_size]
            cursor.executemany(multidimensional_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} многомерных записей")
        
        # Генерация текстовых данных
        print("Генерация 20,000 текстовых записей...")
        text_data = generate_text_data(20000)
        
        print("Вставка текстовых данных в БД...")
        text_sql = """
            INSERT INTO text_data (word, language, frequency, part_of_speech) 
            VALUES (%s, %s, %s, %s)
        """
        
        for i in range(0, len(text_data), batch_size):
            batch = text_data[i:i + batch_size]
            cursor.executemany(text_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} текстовых записей")
        
        # Генерация сетевых данных
        print("Генерация 15,000 сетевых записей...")
        network_data = generate_network_data(15000)
        
        print("Вставка сетевых данных в БД...")
        network_sql = """
            INSERT INTO network_data (ip_address, hostname, network_range, country_code) 
            VALUES (%s, %s, %s, %s)
        """
        
        for i in range(0, len(network_data), batch_size):
            batch = network_data[i:i + batch_size]
            cursor.executemany(network_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} сетевых записей")
        
        # Генерация данных с прямоугольниками
        print("Генерация 10,000 прямоугольников...")
        bounding_boxes_data = generate_bounding_boxes(10000)
        
        print("Вставка прямоугольников в БД...")
        bounding_sql = """
            INSERT INTO bounding_boxes (box_name, bbox, object_type) 
            VALUES (%s, %s, %s)
        """
        
        for i in range(0, len(bounding_boxes_data), batch_size):
            batch = bounding_boxes_data[i:i + batch_size]
            cursor.executemany(bounding_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} прямоугольников")
        
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