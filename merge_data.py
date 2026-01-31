#!/usr/bin/env python3
"""
Merge multiple KE scan results into a single data.json for the web dashboard.

Usage:
    python merge_data.py <output.json> <input1.json> [input2.json ...]

Input format (from ke_scan.py):
    {
        "months": 6,
        "seats": 1,
        "classes": ["business", "first"],
        "results": {
            "ICN-LAX": {
                "2026-05-01": ["business"],
                "2026-05-15": ["business", "first"]
            }
        }
    }

Output format:
    {
        "updatedAt": "2026-02-01 01:30:00 KST",
        "routes": {
            "ICN-LAX": {
                "2026-05-01": ["business"],
                "2026-05-15": ["business", "first"]
            }
        }
    }
"""

import json
import sys
from pathlib import Path
from datetime import datetime


def main():
    if len(sys.argv) < 3:
        print("Usage: merge_data.py <output_json> <input_json_1> [input_json_2 ...]")
        sys.exit(1)

    out_path = Path(sys.argv[1])
    inputs = sys.argv[2:]

    combined = {
        "updatedAt": datetime.now().strftime("%Y-%m-%d %H:%M:%S KST"),
        "routes": {}
    }

    for inp in inputs:
        p = Path(inp)
        if not p.exists():
            print(f"⚠️  Skipping missing file: {inp}")
            continue
        
        try:
            content = p.read_text(encoding='utf-8')
            
            # Handle empty files
            if not content.strip():
                print(f"⚠️  Skipping empty file: {inp}")
                continue
            
            data = json.loads(content)
            
            # Extract results from scanner output
            results = data.get("results", {})
            
            if not results:
                print(f"⚠️  No results found in: {inp}")
                continue
            
            # Merge routes
            for route, dates in results.items():
                if route not in combined["routes"]:
                    combined["routes"][route] = {}
                
                # Merge dates for this route
                combined["routes"][route].update(dates)
                
            print(f"✅ Merged {len(results)} routes from {p.name}")
            
        except json.JSONDecodeError as e:
            print(f"❌ JSON error in {inp}: {e}")
            continue
        except Exception as e:
            print(f"❌ Error reading {inp}: {e}")
            continue

    # Write output
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(
        json.dumps(combined, ensure_ascii=False, indent=2),
        encoding='utf-8'
    )
    
    total_routes = len(combined["routes"])
    total_dates = sum(len(dates) for dates in combined["routes"].values())
    
    print("")
    print(f"📊 Summary:")
    print(f"   Routes: {total_routes}")
    print(f"   Total dates: {total_dates}")
    print(f"   Output: {out_path}")


if __name__ == "__main__":
    main()
