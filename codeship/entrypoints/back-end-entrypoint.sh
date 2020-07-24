#!/bin/bash
set -e

until psql -h "postgres" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 5
done

>&2 echo "Postgres is up - executing command"

bundle exec bin/rails db:environment:set RAILS_ENV=development

>&2 echo "Resetting DB"
bundle exec rake db:migrate:reset

>&2 echo "Seeding DB"
bundle exec rake db:seed

>&2 echo "Starting Rails"
bundle exec rails s -p 4000 -b '0.0.0.0'
