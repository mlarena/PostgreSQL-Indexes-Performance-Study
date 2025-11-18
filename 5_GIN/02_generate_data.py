#!/usr/bin/env python3
"""
Генератор тестовых данных для GIN индекса
Генерирует данные для тестирования массивов, JSONB и полнотекстового поиска
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

def generate_products_data(num_records):
    """Генерация данных продуктов с массивами и JSON"""
    fake = Faker()
    products = []
    
    # Базовые наборы данных
    all_tags = ['electronics', 'home', 'kitchen', 'sports', 'books', 'clothing', 
                'beauty', 'toys', 'garden', 'office', 'digital', 'premium',
                'sale', 'new', 'bestseller', 'eco-friendly', 'handmade']
    
    categories = {
        'electronics': ['smartphone', 'laptop', 'tablet', 'headphones', 'camera'],
        'home': ['furniture', 'decor', 'lighting', 'storage'],
        'kitchen': ['appliances', 'cookware', 'utensils', 'storage'],
        'clothing': ['men', 'women', 'kids', 'accessories'],
        'books': ['fiction', 'non-fiction', 'educational', 'children']
    }
    
    for i in range(num_records):
        # Выбираем основную категорию
        main_category = random.choice(list(categories.keys()))
        subcategories = categories[main_category]
        
        # Генерируем теги (3-8 штук)
        num_tags = random.randint(3, 8)
        tags = random.sample(all_tags, num_tags)
        tags.append(main_category)
        
        # Генерируем категории
        num_cats = random.randint(1, 3)
        product_categories = random.sample(subcategories, min(num_cats, len(subcategories)))
        
        # Генерируем цены (массив из 1-4 цен)
        base_price = round(random.uniform(10, 1000), 2)
        num_prices = random.randint(1, 4)
        prices = [round(base_price * (1 + i * 0.1), 2) for i in range(num_prices)]
        
        # Генерируем JSON атрибуты
        attributes = {
            'weight': round(random.uniform(0.1, 50.0), 2),
            'dimensions': {
                'width': round(random.uniform(5, 100), 1),
                'height': round(random.uniform(5, 100), 1),
                'depth': round(random.uniform(5, 100), 1)
            },
            'features': random.sample(['wireless', 'waterproof', 'energy-saving', 'smart', 'portable'], 
                                    random.randint(1, 3)),
            'warranty_months': random.randint(0, 36),
            'in_stock': random.choice([True, False])
        }
        
        product = (
            fake.catch_phrase()[:200],
            fake.paragraph()[:500],
            tags,
            product_categories,
            prices,
            json.dumps(attributes)
        )
        products.append(product)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} продуктов")
    
    return products

def generate_user_profiles(num_records):
    """Генерация профилей пользователей с JSON данными"""
    fake = Faker()
    profiles = []
    used_usernames = set()  # Множество для отслеживания использованных имен
    
    for i in range(num_records):
        # Генерируем уникальное имя пользователя
        while True:
            username = fake.user_name()[:50]
            if username not in used_usernames:
                used_usernames.add(username)
                break
        
        # Основные данные профиля
        profile_data = {
            'personal': {
                'first_name': fake.first_name(),
                'last_name': fake.last_name(),
                'birth_date': fake.date_of_birth(minimum_age=18, maximum_age=80).isoformat(),
                'gender': random.choice(['male', 'female', 'other']),
                'phone': fake.phone_number()
            },
            'address': {
                'street': fake.street_address(),
                'city': fake.city(),
                'country': fake.country(),
                'zipcode': fake.zipcode()
            },
            'employment': {
                'company': fake.company(),
                'position': fake.job(),
                'industry': random.choice(['IT', 'Finance', 'Healthcare', 'Education', 'Retail'])
            }
        }
        
        # Настройки пользователя
        preferences = {
            'notifications': {
                'email': random.choice([True, False]),
                'sms': random.choice([True, False]),
                'push': random.choice([True, False])
            },
            'privacy': {
                'profile_visible': random.choice([True, False]),
                'search_visible': random.choice([True, False])
            },
            'theme': random.choice(['light', 'dark', 'auto']),
            'language': random.choice(['en', 'ru', 'de', 'fr', 'es'])
        }
        
        # Лог активности (JSON массив)
        activity_log = []
        num_activities = random.randint(1, 5)
        for _ in range(num_activities):
            activity = {
                'action': random.choice(['login', 'view', 'purchase', 'search', 'update_profile']),
                'timestamp': fake.iso8601(),
                'ip': fake.ipv4(),
                'user_agent': fake.user_agent()
            }
            activity_log.append(activity)
        
        profile = (
            username,  # Уникальное имя пользователя
            json.dumps(profile_data),
            json.dumps(preferences),
            json.dumps(activity_log)
        )
        profiles.append(profile)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} профилей")
    
    return profiles

def generate_articles_data(num_records):
    """Генерация статей для полнотекстового поиска"""
    fake = Faker()
    articles = []
    
    # Ключевые слова для статей
    all_keywords = ['technology', 'science', 'health', 'education', 'business', 
                   'politics', 'sports', 'entertainment', 'travel', 'food',
                   'AI', 'machine learning', 'blockchain', 'cloud', 'security',
                   'innovation', 'startup', 'digital', 'sustainable', 'global']
    
    for i in range(num_records):
        # Генерируем контент статьи
        title = fake.sentence()[:300]
        
        # Создаем реалистичный контент с несколькими параграфами
        paragraphs = []
        for _ in range(random.randint(3, 8)):
            paragraphs.append(fake.paragraph())
        content = '\n\n'.join(paragraphs)
        
        # Выбираем ключевые слова (3-6 штук)
        num_keywords = random.randint(3, 6)
        keywords = random.sample(all_keywords, num_keywords)
        
        # Метаданные статьи
        metadata = {
            'word_count': len(content.split()),
            'reading_time': round(len(content.split()) / 200),  # минут
            'category': random.choice(['news', 'tutorial', 'opinion', 'research', 'review']),
            'topics': random.sample(['AI', 'cloud', 'security', 'development', 'data'], 
                                  random.randint(1, 3)),
            'is_featured': random.choice([True, False]),
            'is_premium': random.choice([True, False])
        }
        
        article = (
            title,
            content,
            fake.name(),
            keywords,
            json.dumps(metadata)
        )
        articles.append(article)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} статей")
    
    return articles

def generate_documents_data(num_records):
    """Генерация документов с различными свойствами"""
    fake = Faker()
    documents = []
    
    doc_types = ['contract', 'report', 'proposal', 'manual', 'policy', 'guideline']
    access_levels = ['public', 'internal', 'confidential', 'secret']
    
    for i in range(num_records):
        doc_type = random.choice(doc_types)
        
        # Свойства документа
        properties = {
            'document_id': fake.uuid4(),
            'version': random.randint(1, 10),
            'status': random.choice(['draft', 'review', 'approved', 'archived']),
            'department': random.choice(['HR', 'Finance', 'IT', 'Marketing', 'Operations']),
            'author': fake.name(),
            'reviewers': [fake.name() for _ in range(random.randint(1, 3))],
            'effective_date': fake.date_this_decade().isoformat(),
            'expiry_date': fake.future_date().isoformat()
        }
        
        # Вложения
        num_attachments = random.randint(0, 3)
        attachments = []
        for _ in range(num_attachments):
            attachment_type = random.choice(['pdf', 'doc', 'xls', 'image', 'zip'])
            attachment_name = f"{fake.word()}.{attachment_type}"
            attachments.append(attachment_name)
        
        # Права доступа
        num_access = random.randint(1, 3)
        access_control = random.sample(access_levels, num_access)
        
        document = (
            doc_type,
            fake.catch_phrase()[:200],
            fake.text()[:1000],
            json.dumps(properties),
            attachments,
            access_control
        )
        documents.append(document)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} документов")
    
    return documents

def generate_log_entries(num_records):
    """Генерация лог-записей"""
    fake = Faker()
    log_entries = []
    
    log_levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']
    all_tags = ['authentication', 'database', 'api', 'security', 'performance', 
               'payment', 'notification', 'cache', 'network', 'storage']
    
    for i in range(num_records):
        log_level = random.choice(log_levels)
        
        # Контекст лога
        context = {
            'request_id': fake.uuid4(),
            'session_id': fake.uuid4(),
            'user_id': random.randint(1, 10000),
            'endpoint': f"/api/{fake.uri_path()}",
            'method': random.choice(['GET', 'POST', 'PUT', 'DELETE']),
            'status_code': random.choice([200, 201, 400, 401, 403, 404, 500]),
            'response_time_ms': random.randint(10, 5000),
            'timestamp': fake.iso8601()
        }
        
        # Теги для фильтрации
        num_tags = random.randint(1, 4)
        tags = random.sample(all_tags, num_tags)
        tags.append(log_level.lower())
        
        log_entry = (
            log_level,
            fake.sentence(),
            json.dumps(context),
            tags,
            fake.ipv4(),
            fake.user_agent()
        )
        log_entries.append(log_entry)
        
        if i % 10000 == 0 and i > 0:
            print(f"Сгенерировано {i} лог-записей")
    
    return log_entries

def main():
    config = DB_CONFIG.copy()
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Устанавливаем схему
        cursor.execute("SET search_path TO GIN")
        
        print("Генерация данных для GIN индексов...")
        
        # Генерация продуктов
        print("Генерация 25,000 продуктов...")
        products_data = generate_products_data(25000)
        
        print("Вставка продуктов в БД...")
        products_sql = """
            INSERT INTO products (name, description, tags, categories, prices, attributes) 
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        
        batch_size = 1000
        for i in range(0, len(products_data), batch_size):
            batch = products_data[i:i + batch_size]
            cursor.executemany(products_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} продуктов")
        
        # Генерация профилей пользователей
        print("Генерация 20,000 профилей...")
        profiles_data = generate_user_profiles(20000)
        
        print("Вставка профилей в БД...")
        profiles_sql = """
            INSERT INTO user_profiles (username, profile_data, preferences, activity_log) 
            VALUES (%s, %s, %s, %s)
        """
        
        success_count = 0
        for i in range(0, len(profiles_data), batch_size):
            batch = profiles_data[i:i + batch_size]
            try:
                cursor.executemany(profiles_sql, batch)
                conn.commit()
                success_count += len(batch)
                print(f"Вставлено {success_count} профилей")
            except psycopg2.IntegrityError as e:
                conn.rollback()
                print(f"Обнаружены дубликаты в пакете, вставляем по одному...")
                # Вставляем по одному, пропуская дубликаты
                for record in batch:
                    try:
                        cursor.execute(profiles_sql, record)
                        conn.commit()
                        success_count += 1
                    except psycopg2.IntegrityError:
                        conn.rollback()
                        continue
                print(f"Вставлено {success_count} профилей (некоторые дубликаты пропущены)")
            except Exception as e:
                conn.rollback()
                print(f"Ошибка при вставке профилей: {e}")
                # Продолжаем с следующим пакетом
                continue
        
        # Генерация статей
        print("Генерация 30,000 статей...")
        articles_data = generate_articles_data(30000)
        
        print("Вставка статей в БД...")
        articles_sql = """
            INSERT INTO articles (title, content, author, keywords, metadata) 
            VALUES (%s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(articles_data), batch_size):
            batch = articles_data[i:i + batch_size]
            cursor.executemany(articles_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} статей")
        
        # Генерация документов
        print("Генерация 15,000 документов...")
        documents_data = generate_documents_data(15000)
        
        print("Вставка документов в БД...")
        documents_sql = """
            INSERT INTO documents (doc_type, title, content, properties, attachments, access_control) 
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(documents_data), batch_size):
            batch = documents_data[i:i + batch_size]
            cursor.executemany(documents_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} документов")
        
        # Генерация лог-записей
        print("Генерация 40,000 лог-записей...")
        log_entries_data = generate_log_entries(40000)
        
        print("Вставка лог-записей в БД...")
        log_sql = """
            INSERT INTO log_entries (log_level, message, context, tags, ip_address, user_agent) 
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        
        for i in range(0, len(log_entries_data), batch_size):
            batch = log_entries_data[i:i + batch_size]
            cursor.executemany(log_sql, batch)
            conn.commit()
            print(f"Вставлено {i + len(batch)} лог-записей")
        
        # Обновляем search_vector для полнотекстового поиска
        print("Обновление search_vector для полнотекстового поиска...")
        cursor.execute("""
            UPDATE articles 
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