"""
didExtract.py
Author: Frank Gadot <frank@hermes42.com>

This new Python iteration of the old Shell script reads users.txt and translator.txt files from Alcatel OXE
and extracts DID-to-Extension mappings.
"""

import csv
import sys

def clean_string(value):
    """ Trim whitespace and remove unwanted characters """
    return value.strip() if value else ""

def normalize_did(value):
    """ Normalize DID to ensure matching (remove leading zeros, trim spaces) """
    value = clean_string(value)
    return str(int(value)) if value.isdigit() else value

def read_users_file(users_file):
    """ Reads users.txt and extracts Extension, First Name, Last Name """
    users_data = {}

    with open(users_file, encoding="utf-8") as f:
        reader = csv.reader(f, delimiter="\t")
        next(reader)  # Skip header row

        for row in reader:
            if len(row) < 6:
                continue  # Skip malformed lines

            extension = normalize_did(row[2])  # User Extension (NOT DID)
            first_name = clean_string(row[4])  # First Name
            last_name = clean_string(row[3])  # Last Name

            users_data[extension] = (first_name, last_name)  # Store in dictionary

    print(f"✅ Loaded {len(users_data)} user extensions from {users_file}")
    return users_data

def read_translator_file(translator_file):
    """ Reads translator.txt and extracts DID-Extension mappings """
    did_to_extension = {}
    processing = False  # Start reading only after finding "Node"

    with open(translator_file, encoding="utf-8") as f:
        for line in f:
            line = line.strip()

            # ✅ Detect "Node" line and start processing
            if not processing:
                if "Node" in line:
                    processing = True
                    print(f"✅ Found start line: {line}")
                continue  # Skip everything before "Node"

            # ✅ Split line by tab, ignoring spaces
            row = [clean_string(col) for col in line.split("\t")]

            if len(row) < 8:  # ✅ Ensure we have enough columns
                continue  

            did = normalize_did(row[4])  # ✅ Column 5: First External Number (DID)
            extension = normalize_did(row[5])  # ✅ Column 6: First Internal Number (Extension)
            range_size = clean_string(row[6])  # ✅ Column 7: Range Size
            unique_internal = clean_string(row[7])  # ✅ Column 8: Unique Internal Number

            if not did or not extension:
                continue  # ✅ Skip invalid rows

            if range_size.isdigit():
                range_size = int(range_size)

                if unique_internal.upper() == "YES":
                    for i in range(range_size):
                        did_to_extension[str(int(did) + i)] = extension
                else:
                    for i in range(range_size):
                        did_to_extension[str(int(did) + i)] = str(int(extension) + i)
            else:
                did_to_extension[did] = extension

    print(f"✅ Loaded {len(did_to_extension)} DID-to-Extension mappings from {translator_file}")
    return did_to_extension

def generate_csv(users_file, translator_file, output_file):
    """ Joins the extracted DID data and writes the final CSV """
    users_data = read_users_file(users_file)
    did_to_extension = read_translator_file(translator_file)

    if not did_to_extension:
        print("⚠️ No DID mappings found! Check translator.txt formatting.")
    
    if not users_data:
        print("⚠️ No user extensions found! Check users.txt formatting.")

    with open(output_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["DID", "Extension", "FirstName", "LastName"])

        count = 0
        for did, extension in did_to_extension.items():
            if extension in users_data:
                first_name, last_name = users_data[extension]
            else:
                first_name, last_name = "EXTENSION", "NOT ASSIGNED"

            writer.writerow([did, extension, first_name, last_name])
            count += 1

    print(f"✅ Wrote {count} records to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 didExtract.py <users.txt> <translator.txt>")
        sys.exit(1)

    users_file = sys.argv[1]
    translator_file = sys.argv[2]
    output_file = "DIDtoExtensions.csv"

    generate_csv(users_file, translator_file, output_file)
