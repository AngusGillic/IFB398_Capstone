import json
import socket
import sys
import threading
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

import boto3
from moto import mock_aws

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'pets'))

from app import handle_request
from service import PetService
from store import PetStore


class PetsServer(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def do_GET(self):
        self.handle_pet_request()

    def do_PUT(self):
        self.handle_pet_request()

    def do_POST(self):
        self.handle_pet_request()

    def handle_pet_request(self):
        body = self.rfile.read(int(self.headers.get('Content-Length', 0))).decode()
        token = self.headers.get('Authorization', '')
        if self.path.startswith('/_test/'):
            if token != 'Bearer fixture-admin':
                self.send_json(401, {'message': 'Fixture administrator required'})
                return
            if self.path == '/_test/shutdown':
                self.send_json(200, {})
                threading.Thread(target=self.server.shutdown, daemon=True).start()
                return
            if self.path == '/_test/trips':
                trip = json.loads(body)
                result = self.server.service.credit_trip(
                    trip['owner'], trip['trip_id'], trip['co2_saved_kg'],
                )
                self.send_json(200, result)
                return
            self.send_json(404, {})
            return

        # The local fixture supplies claims; Cognito verification is outside this test.
        owner = token[len('Bearer fixture-'):] if token.startswith('Bearer fixture-') else ''
        event = {
            'routeKey': self.command + ' ' + self.path,
            'requestContext': {'authorizer': {'jwt': {'claims': {
                'sub': owner, 'token_use': 'access',
            }}}},
            'body': body,
        }
        result = handle_request(event, self.server.service)
        if self.headers.get('X-Test-Drop-Response') == '1':
            self.connection.shutdown(socket.SHUT_RDWR)
            self.connection.close()
            return
        self.send_json(result['statusCode'], json.loads(result['body']))

    def send_json(self, status, body):
        encoded = json.dumps(body).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)


def main():
    with mock_aws():
        client = boto3.client('dynamodb', region_name='ap-southeast-2')
        client.create_table(
            TableName='pets', BillingMode='PAY_PER_REQUEST',
            AttributeDefinitions=[
                {'AttributeName': 'owner', 'AttributeType': 'S'},
                {'AttributeName': 'record', 'AttributeType': 'S'},
            ],
            KeySchema=[
                {'AttributeName': 'owner', 'KeyType': 'HASH'},
                {'AttributeName': 'record', 'KeyType': 'RANGE'},
            ],
        )
        with HTTPServer(('127.0.0.1', 0), PetsServer) as server:
            server.service = PetService(PetStore('pets', client),
                                        lambda: datetime.now(timezone.utc))
            print(json.dumps({'port': server.server_port}), flush=True)
            server.serve_forever()


if __name__ == '__main__':
    main()
