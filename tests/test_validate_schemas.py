from unittest import TestCase
from json import loads
from jsonschema import validate
from jsonschema.exceptions import SchemaError, ValidationError
import os

# Fixtures
dirname = os.path.dirname(__file__)
testdata_dir = os.path.abspath(os.path.join(dirname, "data/"))
schema_dir = os.path.abspath(os.path.join(dirname, "../elixir-lu-json-schemas"))
schema_testdata_filename_map = [
    ('elu-dataset.json', 'datasets.json'),
    ('elu-project.json', 'projects.json'),
    ('elu-institution.json', 'partners.json')
    ]


class TestJSONSchemas(TestCase):

    def test_validation(self):
        for schema_filename, dataset_filename in schema_testdata_filename_map:
            schema_filepath = os.path.abspath(os.path.join(schema_dir, schema_filename))
            schemaFile = open(os.path.join(schema_dir, schema_filename), encoding='utf-8')

            data_filepath = os.path.abspath(os.path.join(testdata_dir, dataset_filename))
            dataFile = open(data_filepath, encoding='utf-8')

            schema = loads(schemaFile.read())
            data = loads(dataFile.read())['items']

            for item in data:
                try:
                    validate(item, schema)
                    self.assertTrue(True)
                except SchemaError:
                    self.fail(f"JSONSchema {schema_filepath} is not valid - SchemaError.")
                except ValidationError:
                    self.fail(f"JSONSchema {schema_filepath} is not valid - failed on test data {data_filepath}")
                finally:
                    dataFile.close()
                    schemaFile.close()
