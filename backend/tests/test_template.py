import os
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from samtranslator.translator.transform import transform
from samtranslator.yaml_helper import yaml_parse


class TemplateTests(unittest.TestCase):
    def test_template_transforms_and_every_api_route_requires_cognito(self):
        path = Path(__file__).resolve().parents[1] / 'template.yaml'
        template = yaml_parse(path.read_text())
        for resource in template['Resources'].values():
            if resource['Type'] == 'AWS::Serverless::Function':
                resource['Properties']['CodeUri'] = 's3://test-artifacts/pets.zip'
        with patch.dict(os.environ, {'AWS_DEFAULT_REGION': 'ap-southeast-2'}):
            translated = transform(template, {
                'CognitoUserPoolId': 'ap-southeast-2_test',
                'CognitoAppClientId': 'test-client',
                'WebOrigin': 'https://travelly.example',
            }, SimpleNamespace(load=lambda: {}))

        resources = translated['Resources']
        definition = resources['PetsApi']['Properties']['Body']
        routes = definition['paths']
        self.assertEqual(len(routes), 5)
        for route in routes.values():
            for method in route.values():
                self.assertEqual(method['security'], [
                    {'Cognito': ['aws.cognito.signin.user.admin']},
                ])
        self.assertEqual(resources['PetsTable']['DeletionPolicy'], 'Retain')
        for resource in resources.values():
            if resource['Type'] == 'AWS::Lambda::Permission':
                self.assertNotEqual(resource['Properties']['FunctionName'],
                                    {'Ref': 'TripCreditFunction'})


if __name__ == '__main__':
    unittest.main()
