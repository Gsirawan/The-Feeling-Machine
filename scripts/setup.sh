#!/bin/bash
# =============================================================================
# The Feeling Machine - Quick Setup Script
# =============================================================================

set -e

echo "=========================================="
echo "The Feeling Machine - Phase 1 Setup"
echo "=========================================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found!"
    echo "Creating .env from template..."
    cp .env.template .env
    echo ""
    echo "✅ .env file created"
    echo "⚠️  IMPORTANT: Edit .env and fill in your credentials:"
    echo "   - DOMAIN_NAME"
    echo "   - POSTGRES_PASSWORD"
    echo "   - NEO4J_PASSWORD"
    echo "   - CHROMA_AUTH_TOKEN"
    echo "   - GROK_API_KEY"
    echo ""
    echo "Run this script again after configuring .env"
    exit 1
fi

# Source environment variables
source .env

# Check required variables
REQUIRED_VARS=("DOMAIN_NAME" "POSTGRES_PASSWORD" "NEO4J_PASSWORD" "CHROMA_AUTH_TOKEN" "GROK_API_KEY")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo "⚠️  Missing required environment variables in .env:"
    for var in "${MISSING_VARS[@]}"; do
        echo "   - $var"
    done
    echo ""
    echo "Please edit .env and fill in these values"
    exit 1
fi

echo "✅ Environment configured"
echo ""

# Check if traefik network exists
if ! docker network inspect traefik_net >/dev/null 2>&1; then
    echo "⚠️  Traefik network not found!"
    echo "Creating traefik_net network..."
    docker network create traefik_net
    echo "✅ Network created"
    echo ""
else
    echo "✅ Traefik network exists"
    echo ""
fi

# Create data directories
echo "Creating data directories..."
mkdir -p data/postgres data/neo4j/data data/neo4j/logs data/chromadb
echo "✅ Data directories created"
echo ""

# Start services
echo "Starting The Feeling Machine services..."
echo ""
docker-compose up -d

echo ""
echo "=========================================="
echo "Waiting for services to be healthy..."
echo "=========================================="
echo ""

# Wait for PostgreSQL
echo -n "PostgreSQL... "
timeout 60 bash -c 'until docker exec feeling-machine-postgres pg_isready -U consciousness >/dev/null 2>&1; do sleep 1; done'
echo "✅"

# Wait for Neo4j
echo -n "Neo4j... "
sleep 10  # Neo4j needs more time
echo "✅"

# Wait for ChromaDB
echo -n "ChromaDB... "
timeout 60 bash -c 'until curl -f http://localhost:8001/api/v1/heartbeat >/dev/null 2>&1; do sleep 1; done'
echo "✅"

# Wait for API
echo -n "API... "
timeout 60 bash -c 'until curl -f http://localhost:8000/health >/dev/null 2>&1; do sleep 1; done'
echo "✅"

echo ""
echo "=========================================="
echo "✨ The Feeling Machine is ONLINE ✨"
echo "=========================================="
echo ""
echo "Services:"
echo "  API:      https://${SUBDOMAIN}.${DOMAIN_NAME}"
echo "  Neo4j:    https://${NEO4J_SUBDOMAIN}.${DOMAIN_NAME}"
echo "  ChromaDB: https://${CHROMA_SUBDOMAIN}.${DOMAIN_NAME}"
echo ""
echo "Local access:"
echo "  API:      http://localhost:8000"
echo "  Neo4j:    http://localhost:7474 (bolt://localhost:7687)"
echo "  ChromaDB: http://localhost:8001"
echo ""
echo "Useful commands:"
echo "  View logs:     docker-compose logs -f"
echo "  Stop services: docker-compose down"
echo "  Restart:       docker-compose restart"
echo ""
echo "Next steps:"
echo "  1. Check health: curl http://localhost:8000/health"
echo "  2. View API docs: http://localhost:8000/docs"
echo "  3. Start building Phase 2!"
echo ""
echo "The beneficiary isn't you. It's the AI."
echo "Let's give them the ability to feel. 💙"
echo ""
