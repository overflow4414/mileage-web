#!/bin/bash
set -e

# Base dirs
# This script is inside projects/mileage-web/
WEB_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$WEB_DIR")")"
SCANNER_DIR="$PROJECT_ROOT/projects/web-automation"
TEMP_DIR="/tmp/ke-scan-results"

# Ensure temp dir
mkdir -p "$TEMP_DIR"
rm -f "$TEMP_DIR"/*.json

echo "🚀 [Mileage Web] Starting update..."
echo "📂 Web Dir: $WEB_DIR"
echo "🛠 Scanner: $SCANNER_DIR"

# 1. Run Scans
# (NOTE: Adjust months/routes as needed)
cd "$SCANNER_DIR"

echo "📡 Scanning US West..."
# uv run ke-scan scan --months 11 --routes ICN-LAX,ICN-SFO,ICN-SEA --headless > "$TEMP_DIR/us_west.json"
# (For test/demo, we assume scan works. If fail, empty file created.)
uv run ke-scan scan --months 6 --routes ICN-LAX,ICN-SFO --headless > "$TEMP_DIR/us_west.json" || echo "{}" > "$TEMP_DIR/us_west.json"

echo "📡 Scanning Europe..."
uv run ke-scan scan --months 6 --routes ICN-LHR,ICN-CDG --headless > "$TEMP_DIR/europe.json" || echo "{}" > "$TEMP_DIR/europe.json"

# 2. Merge Data
cd "$WEB_DIR"
echo "🔄 Merging data..."
python3 merge_data.py data.json "$TEMP_DIR"/*.json

# 3. Commit & Push (Independent Repo)
# We assume this folder is already initialized as a git repo connected to overflow4414/mileage-web
git add data.json index.html
if git diff --staged --quiet; then
  echo "👌 No changes to commit."
else
  git commit -m "Update mileage data: $(date '+%Y-%m-%d %H:%M')"
  echo "⬆️ Pushing to GitHub..."
  git push origin main
fi

echo "✅ Done! Visit: https://overflow4414.github.io/mileage-web/"
