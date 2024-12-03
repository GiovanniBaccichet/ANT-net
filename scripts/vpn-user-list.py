#!/usr/bin/env python3

import csv
import os
from itertools import cycle
import argparse

# Set up argument parsing
parser = argparse.ArgumentParser(description="Process a CSV and add VPN profile names and configurations.")
parser.add_argument("input_csv", help="Input CSV file with user data")
parser.add_argument("-o", "--output_csv", help="Output CSV file name (default: input_csv_with '_output.csv')", default=None)
parser.add_argument("-p", "--vpn_profiles_dir", help="Directory containing VPN profile files", default="vpn-profiles")

# Parse the arguments
args = parser.parse_args()

# Determine output file name (default to appending '_output' to the input file name)
if not args.output_csv:
    output_csv = f"{os.path.splitext(args.input_csv)[0]}_output.csv"
else:
    output_csv = args.output_csv

# Read the input CSV
with open(args.input_csv, mode="r", encoding="utf-8", newline="") as infile:
    reader = csv.DictReader(infile)
    rows = list(reader)
    original_headers = reader.fieldnames  # Capture the original headers

# Get the list of files sorted alphabetically and validate
files = sorted(f for f in os.listdir(args.vpn_profiles_dir) if os.path.isfile(os.path.join(args.vpn_profiles_dir, f)))
if not files:
    raise ValueError(f"No valid files found in the directory: {args.vpn_profiles_dir}")

# Create a cycle of files to ensure all rows have an associated file
files_cycle = cycle(files)

# Add new columns for Profile Name (key_name) and VPN Config (key)
for row in rows:
    file_name = next(files_cycle)  # Get the next file in the cycle
    file_path = os.path.join(args.vpn_profiles_dir, file_name)
    row["Profile Name"] = file_name
    with open(file_path, mode="r", encoding="utf-8") as file:
        row["VPN Config"] = file.read()

# Combine the original headers with the new columns
output_headers = original_headers + ["Profile Name", "VPN Config"]

# Write the updated data to the output CSV
with open(output_csv, mode="w", encoding="utf-8", newline="") as outfile:
    writer = csv.DictWriter(outfile, fieldnames=output_headers, quoting=csv.QUOTE_MINIMAL)
    writer.writeheader()
    writer.writerows(rows)

print(f"[!] Updated CSV saved as: {output_csv}")
