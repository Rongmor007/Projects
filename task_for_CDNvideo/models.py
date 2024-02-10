from sqlalchemy import MetaData, REAL, VARCHAR, Table, Column, Integer, String


metadata = MetaData()

cities = Table(
    'cities',
    metadata,
    Column('name', VARCHAR, primary_key=True),
    Column('latitude', REAL, nullable=False),
    Column('longitude', REAL, nullable=False)
)