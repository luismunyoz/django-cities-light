#!/usr/bin/env bash
set -x
set -e

function do_db() {
    python test_project/manage.py syncdb --traceback --noinput --settings=test_project.$1
    python test_project/manage.py migrate --noinput --traceback --settings=test_project.$1
    python test_project/manage.py cities_light --force-import-all --traceback --settings=test_project.$1
}

pip install south 

if [[ ${TRAVIS_PYTHON_VERSION%%.*} -eq "2" && $DB = 'mysql' ]]; then
    pip install mysql-python 

    # mysql / python 2: way too slow for travis
    export CITIES_LIGHT_CITY_SOURCE=cities15000
fi

if [[ $DB = 'mysql' ]]; then
    # test on mysql
    do_db settings_mysql
fi

if [[ $DB = 'postgresql' ]]; then
    pip install psycopg2
    do_db settings_postgres
fi 

if [[ $DB = 'sqlite' ]]; then
    rm -rf test_project/db.sqlite
    do_db settings
fi
