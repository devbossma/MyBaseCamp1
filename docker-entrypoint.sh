#!/bin/sh
set -e

echo "Starting production application..."

# Create database directory
mkdir -p /usr/src/app/db

# Determine database file
DB_FILE="/usr/src/app/db/${RACK_ENV:-production}.sqlite3"
echo "Using database: $DB_FILE"

# Run migrations if they exist
if [ -f "Rakefile" ] && bundle exec rake -T | grep -q "db:migrate"; then
  echo "Running database migrations..."
  bundle exec rake db:migrate
fi

# Then execute the main command
exec "$@"