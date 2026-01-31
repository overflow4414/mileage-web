#!/bin/bash
set -e

# ============================================
# KE Mileage Web Deployment Script
# ============================================
# This script:
# 1. Scans 6 key routes (LAX, SFO, LAS, LHR, FRA, CDG)
# 2. Merges scan results into data.json
# 3. Commits and pushes to GitHub
# ============================================

# Base dirs
WEB_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$WEB_DIR")")"
SCANNER_DIR="$PROJECT_ROOT/projects/web-automation"
TEMP_DIR="/tmp/ke-scan-results"

# Config
MONTHS=6
CLASSES="business,first"

# Ensure temp dir
mkdir -p "$TEMP_DIR"
rm -f "$TEMP_DIR"/*.json

echo "🚀 [KE Mileage Web] Starting deployment..."
echo "📂 Web Dir: $WEB_DIR"
echo "🛠 Scanner: $SCANNER_DIR"
echo "📅 Scanning $MONTHS months ahead"
echo ""

# Verify scanner exists
if [ ! -d "$SCANNER_DIR" ]; then
    echo "❌ Error: Scanner directory not found at $SCANNER_DIR"
    exit 1
fi

cd "$SCANNER_DIR"

# 1. Run Scans
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📡 Scanning Routes..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# US Routes
echo "🇺🇸 US Routes (LAX, SFO, LAS)..."
uv run ke-scan scan \
    --months "$MONTHS" \
    --classes "$CLASSES" \
    --routes ICN-LAX,ICN-SFO,ICN-LAS \
    --headless \
    > "$TEMP_DIR/us.json" 2>&1 || {
        echo "⚠️  US scan failed, using empty data"
        echo '{"results":{}}' > "$TEMP_DIR/us.json"
    }

# Europe Routes
echo "🇪🇺 Europe Routes (LHR, FRA, CDG)..."
uv run ke-scan scan \
    --months "$MONTHS" \
    --classes "$CLASSES" \
    --routes ICN-LHR,ICN-FRA,ICN-CDG \
    --headless \
    > "$TEMP_DIR/europe.json" 2>&1 || {
        echo "⚠️  Europe scan failed, using empty data"
        echo '{"results":{}}' > "$TEMP_DIR/europe.json"
    }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 2. Merge Data
cd "$WEB_DIR"
echo "🔄 Merging scan results..."

python3 merge_data.py data.json "$TEMP_DIR"/*.json

# Verify output
if [ ! -f "data.json" ]; then
    echo "❌ Error: data.json not created"
    exit 1
fi

echo "✅ Merged data.json ($(wc -c < data.json) bytes)"
echo ""

# 3. Git Operations
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Git commit & push..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

git add data.json index.html README.md

if git diff --staged --quiet; then
    echo "👌 No changes to commit"
else
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M KST')
    git commit -m "Update mileage data: $TIMESTAMP"
    
    echo "⬆️  Pushing to GitHub..."
    git push origin main
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Deployment Complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🌐 Visit: https://overflow4414.github.io/mileage-web/"
    echo "📊 GitHub: https://github.com/overflow4414/mileage-web"
fi

# Cleanup
rm -rf "$TEMP_DIR"
echo ""
echo "🧹 Cleaned up temp files"
