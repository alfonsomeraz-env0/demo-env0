from flask import Flask, jsonify, send_from_directory
import socket, os, time

app = Flask(__name__)
_start = time.time()

@app.route('/')
def index():
    return send_from_directory('/opt/env0-app/static', 'index.html')

@app.route('/api/info')
def info():
    return jsonify({
        'hostname': socket.gethostname(),
        'env':      os.environ.get('APP_ENV', 'dev'),
        'uptime':   int(time.time() - _start),
        'private_ip': os.environ.get('PRIVATE_IP', 'unknown'),
    })

@app.route('/health')
def health():
    return 'OK', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
