#!/bin/bash
set -e

# データベースが存在するか確認
if [ ! -f /api/db/development.sqlite3 ]; then
  echo "Setting up the database..."
  bundle exec rails db:setup
else
  echo "Database already exists. Running migrations..."
  bundle exec rails db:migrate
fi

# サーバーを起動
rm -f tmp/pids/server.pid
exec "$@"