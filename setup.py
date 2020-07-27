#!/usr/bin/env python
# -*- coding: utf-8 -*-

try:
    from setuptools import setup, find_packages
except ImportError:
    from distutils.core import setup

requirements = [
     'jsonschema'
]

test_requirements = [
    'coverage'
]

setup(
    name='elixir-lu-json-schemas',
    version='0.2.0-dev',
    description="A utility tool for validating ELIXIR (meta)data files.",
    packages=find_packages(exclude=['contrib', 'docs', 'tests*']),
    package_dir={'elixir-lu-json-schemas': 'elixir-lu-json-schemas'},
    include_package_data=True,
    install_requires=requirements,
    zip_safe=False,
    keywords=['elixir', 'metadata', 'json', 'schema', 'validation'],
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        # 'Intended Audience :: Developers',
        # 'License :: OSI Approved :: ISC License (ISCL)',
        'Natural Language :: English',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
    ],
    test_suite='tests',
    tests_require=test_requirements,
    extras_require={
        'dev': [
            'tox',
            'pep8',
            'bumpversion',
            'coverage'
        ]
    }
)
