from flask import Flask
import http.client
import ssl
import os
import json

app = Flask(__name__)

k8s_namespace = os.getenv('KUBERNETES_NAMESPACE', 'default')
k8s_url = os.getenv('KUBERNETES_SERVICE_HOST', 'kubernetes.default')
k8s_port = os.getenv('KUBERNETES_SERVICE_PORT', '443')

with open('/var/run/secrets/kubernetes.io/serviceaccount/token', 'r') as f:
    k8s_token = f.read()

@app.route("/")
def get_index():
    return "OK"

@app.route("/deployment/<name>")
def get_deployment_status(name: str):
    def online():
        body = {
            'name': name,
            'status': 'ONLINE',
        }
        return body, 200

    def offline():
        body = {
            'name': name,
            'status': 'OFFLINE',
        }
        return body, 409

    connection = http.client.HTTPSConnection(k8s_url, k8s_port, timeout=1, context=ssl._create_unverified_context())

    try:
        headers = {
            'Authorization': f'Bearer {k8s_token}'
        }

        connection.request('GET', f'/apis/apps/v1/namespaces/{k8s_namespace}/deployments/{name}', None, headers)
        response = connection.getresponse()

        data = response.read()
        if data != None:
            data = json.loads(data.decode('utf-8'))

        if response.status != 200 or data is None:
            print(response.status, response.reason)
            print(data)
            return offline()

        if 'availableReplicas' not in data['status']:
            return offline()

        if data['status']['availableReplicas'] > 0:
            return online()

        return offline()
    finally:
        connection.close()
