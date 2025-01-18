#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <users_file> <translator_file>"
    exit 1
fi

# Assign the arguments to variables
users_file=$1
did_file=$2
temp_users_file="users.tmp"
temp_translator_file="translator.tmp"
final_file="DIDtoExtensions.csv"

# Function to check if the file exists
check_file() {
    if [ ! -f "$1" ]; then
        echo "File $1 does not exist. Exiting."
        exit 1
    fi
}

# Check if the files exist
check_file "$users_file"
check_file "$did_file"

# Function to process the users file
process_users_file() {
    echo "Processing users file: $1"
    # Remove header line and extract Extension, Directory First Name, and Directory Name
    tail -n +2 "$1" | awk -F'\t' '{
        gsub(/^[ \t]+/, "", $5)
        gsub(/^[ \t]+/, "", $4)
        print $3, $5, $4
    }' OFS='\t' > "$temp_users_file"
}

# Function to process the DID file
process_did_file() {
    echo "Processing translator file: $1"
    awk '
    BEGIN {processing=0}
    /^\tNode\tTranslator\tExternal Numbering Plan\tDID numbering translator\tFirst External Number\tFirst Internal Number\tRange Size\tUnique Internal Number\t/ {processing=1; next}
    processing {print $5, $6, $7, $8}' "$1" > "$temp_translator_file"
}

# Function to process DID relationship with Extensions
process_all() {
    echo "\"DID\",\"Extension\",\"FirstName\",\"LastName\"" > $final_file
    while read -r line; do
        # Setup variables
        DID=$(echo -e "${line}" | awk '{print $1}')
        EXTENSION=$(echo -e "${line}" | awk '{print $2}')
        RANGE=$(echo -e "${line}" | awk '{print $3}')
        UNIQUE=$(echo -e "${line}" | awk '{print $4}')
        # Remove any leading or trailing spaces and other non-printing characters from UNIQUE
        UNIQUE=$(echo "${UNIQUE}" | tr -d '\r' | awk '{$1=$1};1')

        # Determine the length of DID and create a format string for printf
        DID_LENGTH=${#DID}
        FORMAT="%0${DID_LENGTH}d"

        # Processing of the DID
        # Is this a single DID Range?
        if [[ ${RANGE} -eq 1 ]]; then
            RESULT="\"${DID}\",\"${EXTENSION}\",\"$(grep -w "${EXTENSION}" "${temp_users_file}" | awk '{gsub(/^[ \t]+/, "", $2); print $2}')\",\"$(grep -w "${EXTENSION}" "${temp_users_file}" | awk '{gsub(/^[ \t]+/, "", $3); print $3}')\""
            echo "${RESULT}" >> $final_file
        else
            # It's not; is it linked to a unique extension?
            if [[ "${UNIQUE}" == "YES" ]]; then
                for ((i = 1; i <= RANGE; i++)); do
                    RESULT="\"${DID}\",\"${EXTENSION}\",\"$(grep -w "${EXTENSION}" "${temp_users_file}" | awk '{gsub(/^[ \t]+/, "", $2); print $2}')\",\"$(grep -w "${EXTENSION}" "${temp_users_file}" | awk '{gsub(/^[ \t]+/, "", $3); print $3}')\""
                    echo "${RESULT}" >> $final_file
                    DID=$(printf "$FORMAT" $((10#$DID + 1)))
                done
            else
                # It's not
                for ((i = 1; i <= RANGE; i++)); do
                    RESULT="\"${DID}\",\"${EXTENSION}\",\"$(grep -w "${EXTENSION}" "${temp_users_file}" | awk '{gsub(/^[ \t]+/, "", $2); print $2}')\",\"$(grep -w "${EXTENSION}" "${temp_users_file}" | awk '{gsub(/^[ \t]+/, "", $3); print $3}')\""
                    echo "${RESULT}" >> $final_file
                    DID=$(printf "$FORMAT" $((10#$DID + 1)))
                    EXTENSION=$(printf "$FORMAT" $((10#$EXTENSION + 1)))
                done
            fi
        fi
    done < "$temp_translator_file"
    echo "Results can be found in ${final_file}"
}

# Call the functions to process the files
process_users_file "$users_file"
process_did_file "$did_file"
process_all
echo ""
