# Конфигурация подключения к БД
DB_CONFIG = {
    'dbname': 'indexes_study',
    'user': 'postgres', 
    'password': '12345678',
    'host': 'localhost',
    'port': '5432'
}

# Настройки генерации данных
GENERATION_CONFIG = {
    'batch_size': 1000,
    'log_progress': True,
    'total_records': 1000000  # 1M записей для тестов
}