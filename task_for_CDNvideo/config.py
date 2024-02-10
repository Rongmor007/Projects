from dotenv import load_dotenv      # Библиотека позволяет забрать из этого файла данные
import os       # Для отдачи значения переменных

load_dotenv()       # Сразу вызывается для забора данных

DB_HOST = os.environ.get("DB_HOST")     # Забирает значение переменной DB_HOST из файла .env 
DB_PORT = os.environ.get("DB_PORT")     # Забирает значение переменной DB_HOST из файла .env 
DB_NAME = os.environ.get("DB_NAME")     # Забирает значение переменной DB_HOST из файла .env 
DB_USER = os.environ.get("DB_USER")     # Забирает значение переменной DB_HOST из файла .env 
DB_PASS = os.environ.get("DB_PASS")     # Забирает значение переменной DB_HOST из файла .env 