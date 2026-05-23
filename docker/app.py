from flask import Flask, jsonify
import pymysql
import os

app = Flask(__name__)

conn = pymysql.connect(
    host=os.environ.get('RDS_ENDPOINT'),
    user=os.environ.get('RDS_USER'),
    password=os.environ.get('RDS_PASSWORD'),
    database=os.environ.get('RDS_DATABASE')
)

@app.route('/scenarios')
def scenarios():
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM scenarios")
    results = cursor.fetchall()
    return jsonify(results)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)