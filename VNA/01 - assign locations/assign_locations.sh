: '
Software: assign_locations.sh
Author: Frank Gadot <frank@hermes42.com>
Version: \V1.0\

Usage, changelog: see README.md file
'

#!/bin/bash
# Database connection parameters
DB_NAME="vaa"
DB_USER="postgres"
DB_PORT="5432"
DB_HOST="localhost"
echo -e "\n\n\n\n\n"

# Clean up the phone.csv file
cat phone.csv | grep -v -e "calling_number" -e "DEFAULT" | sed 's/"//g' > phone.tmp

# Let's look at each extension from the file
while read line; do
    # We grab the extensions one by one
    EXTENSION=$(echo "${line}" | cut -d, -f1)
    # We make sure the extension exists in VNA
    result=$(psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) > 0 FROM directory WHERE number = '${EXTENSION}';" | xargs)
    if [ "${result}" = "t" ]; then
        # Let's find the location ID in VNA
        LOCATION_NAME=$(echo "${line}" | cut -d, -f 3)
        LOCATION_ID=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT id FROM site WHERE name::TEXT ILIKE '%${LOCATION_NAME}%';" | xargs)
        # And update the user
        result=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "UPDATE directory SET site_id = '${LOCATION_ID}' WHERE number = '${EXTENSION}';" | xargs)
        if [ "${result}" = "UPDATE 1" ]; then
            echo "+ ${EXTENSION} correctly assigned to ${LOCATION_NAME}."
        else
            echo "- ${EXTENSION} error."
        fi
    else
        # It does not exist, let's log the error
        echo "! Extension ${EXTENSION} from the ENS export file (phone.csv) is non-existent in the VNA Database"
    fi
done < phone.tmp

# Cleanup temporary files
rm phone.tmp
