: '
Software: import_ens_zones.sh
Author: Frank Gadot <frank@hermes42.com>
Version: \V1.0\

Usage, changelog: see README.md file
'

#!/bin/bash
# Database connection parameters
DB_NAME="vaa"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"
CSV_FILE="zone.csv"
imported=0

# Query to get the site ID and name where name is not empty
QUERY="SELECT id, name FROM tenant WHERE name IS NOT NULL LIMIT 10;"

# Execute the query and store the result
result=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "$QUERY")

# Display the options
echo "Available siteIDs and their tenants:"
echo "$result" | awk -F '|' '{printf "%d. %s - %s\n", NR, $1, $2}'

# Ask the user to choose a default siteID
echo
echo "Please choose a siteID by number (1-10):"
read choice

# Extract the chosen siteID and tenant name
selected=$(echo "$result" | awk -F '|' "NR==$choice {print \$1 \"|\" \$2}" | xargs)
siteID=$(echo "$selected" | cut -d '|' -f1 | xargs)  # Ensure no trailing spaces
tenant_name=$(echo "$selected" | cut -d '|' -f2 | xargs)

# Output the selected tenant name
echo "You have selected tenant: $tenant_name"

# Ask the user for the number of records to import
echo
echo "Please enter the number of records to import (or enter 'all' to import all records):"
read num_records

# Set the maximum number of imports
if [ "$num_records" == "all" ]; then
    max_imports=-1  # Set to -1 for unlimited imports
    num_records_text="all"
else
    max_imports=$num_records
    num_records_text=$num_records
fi

# Ask for confirmation
echo
echo "You are going to import $num_records_text records into tenant $tenant_name. Do you confirm? (yes/no)"
read confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Import canceled."
    exit 1
fi

# Initialize a counter for the number of imports
counter=0

# Create an empty location file which will be used in the assign_locations.sh script
echo "" >> ens_locations

# Function to clean a field by removing double quotes, single quotes, leading spaces, and replacing special characters with dashes
clean_field() {
    echo "$1" | sed "s/^['\"]//;s/['\"]$//;s/^ *//" | sed 's/[^0-9a-zA-Z ]/-/g'
}

# Read the CSV file line by line
while IFS=, read -r zone_name outgoing_number address1 unit_type unit_number unit_type2 unit_number2 unit_type3 unit_number3 unit_type4 unit_number4 unit_type5 unit_number5 community postalcode state email_notification emergency_number emergency_responder_1 emergency_responder_2 emergency_responder_3 emergency_responder_4 emergency_responder_5 emergency_responder_6 emergency_responder_7 emergency_responder_8 emergency_responder_9 emergency_responder_10 emergency_responder_11 emergency_responder_12 emergency_responder_13 emergency_responder_14 emergency_responder_15 emergency_responder_16 emergency_responder_17 emergency_responder_18 emergency_responder_19 emergency_responder_20 emergency_responder_21 emergency_responder_22 emergency_responder_23 emergency_responder_24 emergency_responder_25 emergency_responder_26 emergency_responder_27 emergency_responder_28 emergency_responder_29 emergency_responder_30 emergency_responder_31 emergency_responder_32 emergency_responder_33 emergency_responder_34; do
    # Skip the header
    if [ "$counter" -eq 0 ]; then
        counter=$((counter + 1))
        continue
    fi

    # Clean all fields
    zone_name=$(clean_field "$zone_name")
    outgoing_number=$(clean_field "$outgoing_number")
    address1=$(clean_field "$address1")
    unit_type=$(clean_field "$unit_type")
    unit_number=$(clean_field "$unit_number")
    community=$(clean_field "$community")
    postalcode=$(clean_field "$postalcode")
    state=$(clean_field "$state")

    # Truncate the zone_name to 255 characters
    clean_zone_name=$(echo "$zone_name" | cut -c1-255)

    # Split the address into street_number and street_name
    street_number=$(echo "$address1" | awk '{print $1}')
    street_name=$(echo "$address1" | cut -d' ' -f2-)

    # Truncate street_name to 255 characters
    street_name=$(echo "$street_name" | cut -c1-255)

    # Truncate other fields if necessary
    community=$(echo "$community" | cut -c1-255)
    postalcode=$(echo "$postalcode" | cut -c1-255)
    state=$(echo "$state" | cut -c1-255)
    type1=$(echo "$unit_type" | cut -c1-255)
    type1value=$(echo "$unit_number" | cut -c1-255)

    # Generate a UUID V4 for the id
    uuid=$(uuidgen)

    # Display import message
    echo "- Importing $clean_zone_name"

    # Insert into the database
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        INSERT INTO site (id, name, did, street_number, street_name, city, zipcode, state, tenant_id, type1, type1value)
        VALUES ('$uuid', '$clean_zone_name', '$outgoing_number', '$street_number', '$street_name', '$community', '$postalcode', '$state', '$siteID', '$type1', '$type1value');
    " > /dev/null
    imported=$((imported + 1))
    echo -e "${clean_zone_name}\t${uuid}" > ens_locations

    # Increment the counter and check if the maximum number of imports is reached
    if [ "$max_imports" -ne -1 ] && [ "$imported" -ge "$max_imports" ]; then
        echo "Imported $imported records."
        exit 0
    fi
done < "$CSV_FILE"

# Display the total number of records imported
echo "Imported $imported records."
