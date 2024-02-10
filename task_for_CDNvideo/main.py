from fastapi import FastAPI, Response
import psycopg2
import geopy

app = FastAPI()
conn = psycopg2.connect("dbname=test_db user=test_user password=postgres")
cursor = conn.cursor()
geo_service = geopy.geocoders.Nominatim(user_agent='test_user')


@app.get('/cities/{name}')
def get_city(name: str):
    cursor.execute(f'''
        SELECT * FROM cities WHERE name = '{name}';
    ''')
    city = cursor.fetchone()
    if not city:
        return Response(status_code=404)
    return to_dict(city)


@app.post('/cities/add')
def add_city(name: str):
    geo_response = geo_service.geocode(name)
    cursor.execute(f'''
        INSERT INTO cities (name, latitude, longitude) VALUES 
        ('{name}', {geo_response.latitude}, {geo_response.longitude})
        ON CONFLICT DO NOTHING;
    ''')
    cursor.execute('COMMIT')


@app.delete('/cities/{name}')
def delete_city(name: str):
    cursor.execute(f'''
        DELETE FROM cities WHERE name = '{name}';
    ''')
    cursor.execute('COMMIT')


@app.get('/nearest')
def get_nearest_cities(latitude: float, longitude: float):
    cursor.execute(f'''
        SELECT * FROM cities
        ORDER BY ST_DistanceSphere(
            ST_MakePoint(latitude, longitude),
            ST_MakePoint({latitude}, {longitude})
        )
        LIMIT 2;
    ''')
    cities = cursor.fetchall()
    return [to_dict(city) for city in cities]


def to_dict(city: tuple) -> dict:
    return {'name': city[0], 'latitude': city[1], 'longitude': city[2]}
