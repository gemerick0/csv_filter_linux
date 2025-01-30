import csv
import json
import os
import sys
from datetime import datetime

# Check command-line arguments
if len(sys.argv) != 3:
    print("Usage: python filter_csv.py <json_filter_file> <output_csv_file_prefix>")
    sys.exit(1)

json_file = sys.argv[1]
output_file_prefix = sys.argv[2]

# Generate a timestamp for the output file name
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")  # Format: YYYYMMDD_HHMMSS
output_file = os.path.realpath(os.path.join(os.getcwd(), "Output_Files", f"{output_file_prefix}_{timestamp}.csv")) # Directory containing the CSV files


# Load the filter criteria from the JSON file
with open(json_file, 'r') as f:
    filter_criteria = json.load(f)

# Function to check if a row matches the filter criteria
def row_matches(row):
    for column, value in filter_criteria.items():
        if column not in row:
            return False  # Column not found in the row
        if value not in row[column]:  # Check if the value is included in the column's value
            return False
    return True

# Prepare the output CSV file
with open(output_file, 'w', encoding='utf-8', newline='', errors='ignore') as outfile:
    writer = None  # Will be initialized after reading the first CSV

    # Iterate through all CSV files in the input directory
    input_directory = os.path.realpath(os.path.join(os.getcwd(), "Input_Files")) # Directory containing the CSV files
    max_rows_to_search = 1000  # Limit the number of rows to search in each file
    for filename in os.listdir(input_directory):
        if filename.endswith('.csv'):
            filepath = os.path.join(input_directory, filename)
            
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as infile:
                reader = csv.DictReader(infile)
                
                # Initialize the CSV writer if not already done
                if writer is None:
                    fieldnames = reader.fieldnames
                    writer = csv.DictWriter(outfile, fieldnames=fieldnames)
                    writer.writeheader()
                
                # Iterate through rows in the current CSV file
                for i, row in enumerate(reader):
                    if max_rows_to_search == 0:
                        break  # Stop searching after max_rows_to_search
                    
                    # Check if the row matches the filter criteria
                    if row_matches(row):
                        max_rows_to_search -= 1
                        writer.writerow(row)

print(f"Filtered rows have been written to {output_file}")