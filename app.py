# flask run --host 0.0.0.0 --port 5000
from flask import Flask, request
import json
import hmac, hashlib
import subprocess

app = Flask(__name__)

def print_data(request):
    data = request.json
    print('request data', data)

def print_webhook_info():
    signature = request.headers.get('X-Hub-Signature-256', '')
    secret = b'QXfrGgMeqxHTc7XwiKvjq8HtJb18McwBLficysSPtuoWrsKpj08XlKjL6oG3p6pm'
    body = request.data
    expected_signature = 'sha256=' + hmac.new(secret, body, hashlib.sha256).hexdigest()
    if not hmac.compare_digest(signature, expected_signature):
        return 'Request signature didn\'t match', 403

    data = request.json
    head_commit_message = data.get('head_commit').get('message')
    head_commit_author = data.get('head_commit').get('author')
    commit_info = (
        f'webhook received, commit: \n========================\n{head_commit_message}\n========================\n'
        f"authored by {head_commit_author.get('name')}({head_commit_author.get('email')}), building howard-chu-www"
    )
    print(commit_info)

def build() -> bool:
    output = subprocess.run(['sh', 'deploy.sh'], capture_output=True)
    output = subprocess.run(['sh', 'deploy.sh'], capture_output=True)
    stdout = output.stdout.decode('utf-8')
    stderr = output.stderr.decode('utf-8')
    if output.returncode == 0:
        print('\x1b[32m', 'build succeed\n', 'stdout:\n', stdout, '\n', 'stderr:\n', stderr, '\x1b[39m', sep='')
    else:
        print('\x1b[31m', 'fail to build\n', 'stdout:\n', stdout, '\n', 'stderr:\n', stderr, '\x1b[39m', sep='')
    return output.returncode == 0

@app.route('/howard-chu-www/postreceive', methods=['POST'])
def receive_webhook():
    print_webhook_info()
    if not build():
        return 'failed to build', 400
    return 'build success', 200