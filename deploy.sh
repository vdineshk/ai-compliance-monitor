#!/bin/bash
# AI Compliance Monitor - Quick Deploy Script
# Run this on your dev PC after cloning the repo
# Expects CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID to be set

set -e

echo "=== AI Compliance Monitor - Deployment ==="
echo ""

# Check environment variables
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
  echo "❌ CLOUDFLARE_API_TOKEN not set"
  echo "   Set it with: export CLOUDFLARE_API_TOKEN=your_token_here"
  exit 1
fi

if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
  echo "❌ CLOUDFLARE_ACCOUNT_ID not set"
  echo "   Set it with: export CLOUDFLARE_ACCOUNT_ID=your_account_id_here"
  exit 1
fi

echo "✅ Environment variables detected"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
npm install
echo ""

# Create D1 database
echo "🗄️  Creating D1 database..."
DB_OUTPUT=$(npx wrangler d1 create ai-compliance-monitor-db 2>&1 || true)
echo "$DB_OUTPUT"

# Extract database_id from output
DB_ID=$(echo "$DB_OUTPUT" | grep -o 'database_id = "[^"]*"' | head -1 | cut -d'"' -f2)

if [ -z "$DB_ID" ]; then
  echo ""
  echo "⚠️  Could not auto-extract database_id."
  echo "   If database already exists, find your database_id in Cloudflare dashboard"
  echo "   and update wrangler.toml manually."
  echo ""
  echo "   Or paste the database_id here (leave blank to skip):"
  read -r DB_ID
fi

if [ -n "$DB_ID" ]; then
  # Update wrangler.toml with actual database_id
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/YOUR_DATABASE_ID_HERE/$DB_ID/" wrangler.toml
  else
    sed -i "s/YOUR_DATABASE_ID_HERE/$DB_ID/" wrangler.toml
  fi
  echo "✅ Updated wrangler.toml with database_id: $DB_ID"
fi
echo ""

# Run migrations
echo "📋 Running database migrations..."
npx wrangler d1 migrations apply ai-compliance-monitor-db --remote
echo ""

# Seed data
echo "🌱 Seeding regulatory data..."
npx wrangler d1 execute ai-compliance-monitor-db --remote --file=./migrations/0002_seed_data.sql
echo ""

# Dry run first
echo "🔍 Running dry-run deployment..."
npx wrangler deploy --dry-run
echo ""

# Deploy
echo "🚀 Deploying to Cloudflare Workers..."
npx wrangler deploy
echo ""

echo "=== ✅ DEPLOYMENT COMPLETE ==="
echo ""
echo "🌐 MCP Server:  https://ai-compliance-monitor.sgdata.workers.dev/mcp"
echo "📡 REST API:    https://ai-compliance-monitor.sgdata.workers.dev/api"
echo "💚 Health:      https://ai-compliance-monitor.sgdata.workers.dev/"
echo ""
echo "Test it:"
echo "  curl https://ai-compliance-monitor.sgdata.workers.dev/api/obligations?use_case=hiring_screening"
echo ""
