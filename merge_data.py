import json
import sys
from pathlib import Path
from datetime import datetime

# Scan output format from ke_scan.py is basically just prints or simple JSON dump per route?
# Actually ke_scan.py prints line by line or json dump if --out is used.
# We will assume we wrap the output into a consolidated JSON structure.

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
        if not p.exists(): continue
        try:
            data = json.loads(p.read_text())
            # Expected structure from single route scan: { "ICN-LAX": { "2026-05-01": ["business"] } }
            # Or similar. We need to adapt based on actual scanner output.
            # Let's assume the scanner outputs the dict directly.
            for route, dates in data.items():
                if route not in combined["routes"]:
                    combined["routes"][route] = {}
                combined["routes"][route].update(dates)
        except Exception as e:
            print(f"Error reading {inp}: {e}")

    out_path.write_text(json.dumps(combined, ensure_ascii=False, indent=2))
    print(f"Merged {len(inputs)} files into {out_path}")

if __name__ == "__main__":
    main()
