#!/bin/sh



flask db upgrade
flask seed all
exec gunicorn app:app
