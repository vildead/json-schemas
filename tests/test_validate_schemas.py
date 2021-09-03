from unittest import TestCase
from json import loads
from jsonschema import validate, Draft4Validator
from jsonschema.exceptions import SchemaError, ValidationError
import os

# Fixtures
dirname = os.path.dirname(__file__)
testdata_dir = os.path.abspath(os.path.join(dirname, "data/"))
schema_dir = os.path.abspath(os.path.join(dirname, "../schemas"))
schema_testdata_filename_map = [
    ('elu-dataset.json', 'datasets.json'),
    ('elu-project.json', 'projects.json'),
    ('elu-institution.json', 'partners.json')
    ]


class TestJSONSchemas(TestCase):

    def test_validation(self):
        for schema_filename, dataset_filename in schema_testdata_filename_map:
            schema_filepath = os.path.abspath(os.path.join(schema_dir, schema_filename))
            with open(schema_filepath) as f:
                schema = loads(f.read())
            
            data_filepath = os.path.abspath(os.path.join(testdata_dir, dataset_filename))
            with open(data_filepath) as f:
                data  = loads(f.read())['items']

            for item in data:
                try:
                    validate(item, schema)
                    self.assertTrue(True)
                except SchemaError:
                    self.fail(f"JSONSchema {schema_filepath} is not valid - SchemaError.")
                except ValidationError:
                    self.fail(f"JSONSchema {schema_filepath} is not valid - failed on test data {data_filepath}")

    def test_schema_version(self):
        for file in os.listdir(schema_dir):
            try:
                schema_file = open(os.path.join(schema_dir, file), encoding='utf-8')
                schema = loads(schema_file.read())
                Draft4Validator.check_schema(schema)
            finally:
                schema_file.close()
