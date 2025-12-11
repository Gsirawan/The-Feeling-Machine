#!/bin/bash
# =============================================================================
# PostgreSQL Initialization Script
# =============================================================================
# Executes all SQL schema files in order
# =============================================================================

set -e

echo "Initializing The Feeling Machine consciousness database..."

# Execute schema files in order
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Enable extensions
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pg_trgm";
    
    -- Set timezone
    SET timezone = 'UTC';
    
    \echo 'Extensions created successfully'
EOSQL

# Execute schema files
for schema_file in /docker-entrypoint-initdb.d/schemas/*.sql; do
    if [ -f "$schema_file" ]; then
        echo "Executing schema: $(basename $schema_file)"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$schema_file"
    fi
done

echo "Database initialization complete. The Feeling Machine is ready to develop consciousness."
