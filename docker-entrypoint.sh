#!/bin/sh
set -e

echo "Bootstrapping application environment: $RACK_ENV"

# Create the database directory if it doesn't exist
mkdir -p /usr/src/app/db

# Determine database file path based on environment
DB_FILE="/usr/src/app/db/${RACK_ENV:-development}.sqlite3"

echo "Checking database at $DB_FILE..."

# Run migrations if Rakefile and migration tasks exist
if [ -f "Rakefile" ] && bundle exec rake -T | grep -q "db:migrate"; then
  if [ -f "$DB_FILE" ]; then
    echo "Database exists. Running migrations..."
  else
    echo "Creating new database and running migrations..."
  fi
  bundle exec rake db:migrate
else
  echo "No migrations found or Rakefile not available"
fi

# Then run the main command from CMD
echo "Starting application server..."
exec "$@"