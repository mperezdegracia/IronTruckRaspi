from influxdb import InfluxDBClient
import requests
import datetime
import time
import json
import random


class Influx(object):

    def __init__(self, host, port) -> None:
        self.host = host
        self.port = port
        self.client = InfluxDBClient(host, port, retries=5, timeout=2)

    def connect_db(self, dbname):
        '''connect to the database, and create it if it does not exist'''

        print(f'[INFLUX] ---> connecting to database: {self.host}:{self.port}')
        self.wait_for_server()

        create = False
        self.dbname = dbname

        if not self.db_exists():
            create = True
            print(f'[INFLUX] ---> creating database {self.dbname}')
            self.client.create_database(self.dbname)
        else:
            print(f'[INFLUX] ---> database {self.dbname} already exists')

        self.client.switch_database(self.dbname)
        return create  # returns whether it was created or already existed

    def wait_for_server(self, nretries=5, waiting_time=1):
        '''wait for the server to come online for waiting_time, nretries times.'''
        url = f'http://{self.host}:{self.port}'

        for i in range(nretries):
            try:
                requests.get(url)
                return
            except requests.exceptions.ConnectionError:
                print(f'waiting for {url}')
                time.sleep(waiting_time)
                waiting_time *= 2
                pass
        raise DBConnectionError(self.client)

    def db_exists(self):
        '''returns True if the database exists'''
        for db in self.client.get_list_database():
            if db['name'] == self.dbname:
                return True
        return False


class DBConnectionError(Exception):
    def __init__(self, session: Influx) -> None:
        super().__init__(
            f'[DB] --> [ERROR] cant connect to database http://{session.host}:{session.port}')


host = "influxdb"
port = 8086
dbController = Influx(host, port)

dbController.connect_db("IronTruck")
while True:
    for i in range(20):
        data = [{
            'measurement': 'test',
            'time': datetime.datetime.now(),
            'fields': {
                'x': random.randint(1, 40),
            },
        }]
        dbController.client.write_points(data)

    print(dbController.client.query(
        'SELECT * FROM "test" GROUP BY * ORDER BY DESC LIMIT 1'))
