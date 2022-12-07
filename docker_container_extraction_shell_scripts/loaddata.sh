#!/bin/bash

filename="$1"

cd /django/my_site 
python manage.py loaddata $filename.json