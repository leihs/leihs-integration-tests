#!/bin/bash -exu

cd ../database
bundle

dropdb "$DATABASE_NAME" || true

createdb "$DATABASE_NAME"
psql -d "$DATABASE_NAME" -f ./db/structure.sql
./scripts/restore-seeds

bundle exec rails db:migrate

echo OK