#!/usr/bin/env python3
"""
XLSX Batch Converter - Fixed for PwC / Protected Files
"""

import argparse
import shutil
import sys
from pathlib import Path

try:
    import pandas as pd
except ImportError:
    print("Error: pandas is not installed.")
    print("Install it with: pip install pandas openpyxl")
    sys.exit(1)


def setup_folders(root: Path):
    src = root / "src"
    input_dir = src / "input"
    output_dir = src / "output"
    processed_dir = src / "processed"

    input_dir.mkdir(parents=True, exist_ok=True)
    output_dir.mkdir(parents=True, exist_ok=True)
    processed_dir.mkdir(parents=True, exist_ok=True)
    return input_dir, output_dir, processed_dir


def convert_file(xlsx_path: Path, output_dir: Path, all_sheets: bool = False):
    try:
        if all_sheets:
            excel_file = pd.ExcelFile(xlsx_path)
            sheets = excel_file.sheet_names
            for sheet in sheets:
                df = pd.read_excel(xlsx_path, sheet_name=sheet, engine="openpyxl")
                csv_path = output_dir / f"{xlsx_path.stem}_{sheet}.csv"
                df.to_csv(csv_path, index=False, encoding="utf-8")
                print(f"   ✓ {csv_path.name} ({len(df):,} rows)")
        else:
            df = pd.read_excel(xlsx_path, sheet_name=0, engine="openpyxl")
            csv_path = output_dir / f"{xlsx_path.stem}.csv"
            df.to_csv(csv_path, index=False, encoding="utf-8")
            print(f"   ✓ {csv_path.name} ({len(df):,} rows, {len(df.columns)} columns)")
        return True

    except Exception as e:
        error_str = str(e).lower()
        if "zip" in error_str or "not a zip file" in error_str:
            print(f"   ❌ File is not a valid .xlsx (probably password-protected or damaged)")
            print(f"   💡 Fix: Open in Excel → File → Save As → Excel Workbook (*.xlsx)")
        else:
            print(f"   ❌ Failed: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="Batch convert XLSX → CSV")
    parser.add_argument("--root", default=".", help="Root folder")
    parser.add_argument("--all-sheets", action="store_true", help="Convert all sheets")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    print(f"🔄 Starting in root: {root}")

    input_dir, output_dir, processed_dir = setup_folders(root)

    xlsx_files = list(input_dir.glob("*.xlsx")) + list(input_dir.glob("*.XLSX"))
    
    if not xlsx_files:
        print(f"\nNo .xlsx files found in {input_dir}")
        print("   Drop your Excel files into src/input/ and run again.")
        return

    print(f"\nFound {len(xlsx_files)} file(s) to convert...\n")

    success_count = 0
    for xlsx_path in xlsx_files:
        print(f"Processing: {xlsx_path.name}")
        if convert_file(xlsx_path, output_dir, args.all_sheets):
            try:
                shutil.move(str(xlsx_path), processed_dir / xlsx_path.name)
                print(f"   → Moved to processed/{xlsx_path.name}")
                success_count += 1
            except Exception:
                print(f"   ⚠️ Converted but could not move original")
        else:
            print(f"   ⚠️ Skipped moving due to error")

    print("\n" + "="*60)
    print(f"✅ DONE! Successfully converted {success_count}/{len(xlsx_files)} files")
    print(f"   CSVs are in → {output_dir}")
    print(f"   Originals moved to → {processed_dir}")
    print("="*60)


if __name__ == "__main__":
    main()