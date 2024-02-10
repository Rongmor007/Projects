Перед запуском приложения необходимо сделать следующее:
1) Установить postgres
2) Установить в него расширение postgis
3) Создать пользователя test_user, выдать ему пароль: postgres, выдать ему роль суперюзера, создать базу данных test_db
4Запуcтить приложение: uvicorn main:app
5) Прописать команду: alembic revision --autogenerate -m 'Database creation'
6) alembic upgrade 'версию миграции'
7) Прописать команду для установки в БД расширения: CREATE EXTENSION postgis; 
8) Установить пакеты fastapi, psycopg2, geopy
9) Установить uvicorn


Примеры запросов к приложению:
1) Добавить несколько городов:
curl -X POST http://127.0.0.1:8000/cities/add?name=New-York
curl -X POST http://127.0.0.1:8000/cities/add?name=Los-Angeles
curl -X POST http://127.0.0.1:8000/cities/add?name=London
curl -X POST http://127.0.0.1:8000/cities/add?name=Moscow
2) Удалить город:
curl -X DELETE http://127.0.0.1:8000/cities/London
3) Получить город:
curl -X GET http://127.0.0.1:8000/cities/Moscow
4) Получить два ближайших города:
curl -X GET "http://127.0.0.1:8000/nearest?latitude=40&longitude=-70"
