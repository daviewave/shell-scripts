#!/bin/bash

filename="$1"

cd /django/my_site
python manage.py dumpdata --exclude=contenttypes --exclude=auth.Permission -o $filename.json