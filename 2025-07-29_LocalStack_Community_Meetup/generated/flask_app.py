from flask import Flask, jsonify, request
import snowflake.connector
from datetime import datetime

app = Flask(__name__)

@app.route('/init_uploads', methods=['POST'])
def init_uploads():
    conn = snowflake.connector.connect(
        user='test',
        password='test',
        account='test',
        host='snowflake.localhost.localstack.cloud',
        warehouse='COMPUTE_WH',
        database=None,
        schema=None,
        port=443,
        protocol='https'
    )
    try:
        cs = conn.cursor()
        cs.execute('CREATE DATABASE IF NOT EXISTS TESTDB')
        cs.execute('USE DATABASE TESTDB')
        cs.execute('USE SCHEMA PUBLIC')
        cs.execute('''
            CREATE OR REPLACE TABLE uploads (
                file_name TEXT,
                size INTEGER,
                timestamp TIMESTAMP
            )
        ''')
        sample_data = [
            ('file1.txt', 1234, datetime.now()),
            ('file2.jpg', 5678, datetime.now()),
            ('file3.pdf', 91011, datetime.now()),
        ]
        cs.executemany('INSERT INTO uploads (file_name, size, timestamp) VALUES (%s, %s, %s)', sample_data)
        return jsonify({'message': 'Inserted sample records into uploads table.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cs.close()
        conn.close()

@app.route('/add_upload', methods=['POST'])
def add_upload():
    data = request.get_json()
    file_name = data.get('file_name')
    size = data.get('size')
    timestamp = data.get('timestamp')
    if not (file_name and size and timestamp):
        return jsonify({'error': 'Missing required fields'}), 400
    try:
        # Parse timestamp if it's a string
        if isinstance(timestamp, str):
            timestamp = datetime.fromisoformat(timestamp)
    except Exception:
        return jsonify({'error': 'Invalid timestamp format'}), 400
    conn = snowflake.connector.connect(
        user='test',
        password='test',
        account='test',
        host='snowflake.localhost.localstack.cloud',
        warehouse='COMPUTE_WH',
        database='TESTDB',
        schema='PUBLIC',
        port=443,
        protocol='https'
    )
    try:
        cs = conn.cursor()
        cs.execute('INSERT INTO uploads (file_name, size, timestamp) VALUES (%s, %s, %s)', (file_name, size, timestamp))
        return jsonify({'message': 'Record inserted successfully'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cs.close()
        conn.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080) 