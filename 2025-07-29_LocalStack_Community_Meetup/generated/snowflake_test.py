import snowflake.connector
from datetime import datetime

# Connection parameters (update as needed)
conn = snowflake.connector.connect(
    user='test',
    password='test',
    account='test',
    host='snowflake.localhost.localstack.cloud',
    warehouse='COMPUTE_WH',
    database=None,  # Connect without specifying database initially
    schema=None,
    port=443,
    protocol='https'
)

try:
    cs = conn.cursor()
    # Create database if not exists
    cs.execute('CREATE DATABASE IF NOT EXISTS TESTDB')
    cs.execute('USE DATABASE TESTDB')
    cs.execute('USE SCHEMA PUBLIC')
    # Create table with TEXT instead of VARCHAR/STRING
    cs.execute('''
        CREATE OR REPLACE TABLE uploads (
            file_name TEXT,
            size INTEGER,
            timestamp TIMESTAMP
        )
    ''')
    # Insert sample records
    sample_data = [
        ('file1.txt', 1234, datetime.now()),
        ('file2.jpg', 5678, datetime.now()),
        ('file3.pdf', 91011, datetime.now()),
    ]
    cs.executemany('INSERT INTO uploads (file_name, size, timestamp) VALUES (%s, %s, %s)', sample_data)
    print('Inserted sample records into uploads table.')
finally:
    cs.close()
    conn.close() 