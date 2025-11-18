import psycopg2
import time
from datetime import datetime
from database_config import DB_CONFIG

def get_db_connection():
    """Создание подключения к БД"""
    return psycopg2.connect(**DB_CONFIG)

def execute_sql_file(filename, connection):
    """Выполнение SQL файла"""
    with open(filename, 'r', encoding='utf-8') as file:
        sql = file.read()
        with connection.cursor() as cursor:
            cursor.execute(sql)
        connection.commit()

def measure_execution_time(func):
    """Декоратор для измерения времени выполнения"""
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        print(f"Время выполнения: {end_time - start_time:.2f} секунд")
        return result
    return wrapper