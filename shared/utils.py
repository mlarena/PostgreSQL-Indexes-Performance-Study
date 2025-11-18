import psycopg2
import time
from datetime import datetime
from database_config import DB_CONFIG

def get_db_connection():
    """Создание подключения к БД"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except psycopg2.Error as e:
        print(f"Ошибка подключения к БД: {e}")
        raise

def execute_sql_file(filename, connection):
    """Выполнение SQL файла"""
    try:
        with open(filename, 'r', encoding='utf-8') as file:
            sql = file.read()
            with connection.cursor() as cursor:
                cursor.execute(sql)
            connection.commit()
            print(f"Файл {filename} успешно выполнен")
    except Exception as e:
        print(f"Ошибка выполнения файла {filename}: {e}")
        connection.rollback()
        raise

def measure_execution_time(func):
    """Декоратор для измерения времени выполнения"""
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        print(f"Время выполнения: {end_time - start_time:.2f} секунд")
        return result
    return wrapper

def setup_database():
    """Создание базы данных если не существует"""
    try:
        # Подключаемся к postgres БД для создания нашей БД
        config = DB_CONFIG.copy()
        db_name = config.pop('dbname')
        
        conn = psycopg2.connect(**config)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем существование БД
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = %s", (db_name,))
        exists = cursor.fetchone()
        
        if not exists:
            cursor.execute(f"CREATE DATABASE {db_name}")
            print(f"База данных {db_name} создана")
        else:
            print(f"База данных {db_name} уже существует")
            
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"Ошибка настройки БД: {e}")
        raise