from influxdb import InfluxDBClient
import requests
import time

def db_exists():
    '''returns True if the database exists'''
    dbs = client.get_list_database()
    for db in dbs:
        if db['name'] == dbname:
            return True
    return False


def wait_for_server(host, port, nretries=5):
    '''wait for the server to come online for waiting_time, nretries times.'''
    url = 'http://{}:{}'.format(host, port)
    waiting_time = 1
    for i in range(nretries):
        try:
            requests.get(url)
            return
        except requests.exceptions.ConnectionError:
            print('waiting for', url)
            time.sleep(waiting_time)
            waiting_time *= 2
            pass
    print('cannot connect to', url)
    sys.exit(1)


def connect_db(host, port):
    '''connect to the database, and create it if it does not exist'''
    global client
    print('connecting to database: {}:{}'.format(host, port))
    client = InfluxDBClient(host, port, retries=5, timeout=1)
    wait_for_server(host, port)
    create = False
    if not db_exists():
        create = True
        print('creating database...')
        client.create_database(dbname)
    else:
        print('database already exists')
    client.switch_database(dbname)
    if not create and False:
       client.delete_series(measurement=measurement)

if __name__ == '__main__':
    __metaclass__ = type
    client = None
    dbname = 'mydb'
    host = "influxdb"  # '192.168.12.142'
    port = 8086  # 3000
    # INFLUX DB CLIENT
    connect_db(host, port)
    results = client.query('SELECT * FROM "Temp" GROUP BY * ORDER BY DESC LIMIT 1')
    print(results.raw)
