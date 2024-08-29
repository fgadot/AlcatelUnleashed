#!/bin/bash

# protocol_error.sh
# Made by Frank Gadot <frank@hermes42.com>
# This script look at the incident log file for phones with bad protocol.
# The result will show the extension, the set type currently programmed, and the displayed name of the extension
# All you need to do from this list is go and see what type of phone is physically connected for the extension, then change it in the database

# Install in /DHS3data/mao folder
# Allow rights to execute with "chmod 755 protocol_error.sh"
# Run the script with ./protocol_error.sh

# Works up to release 100.1

# This variable must be set to your OXE OS Language.
# English is "Protocol error"
# French is "Erreur protocolaire"
ERROR_MESSAGE="Protocol error"





echo -e "\n\n**********"
echo "protocol_error.sh -> Looking for incident 1612 / $ERROR_MESSAGE / in the incident log..."
# Extract neqt numbers from incvisu
neqt_numbers=$(incvisu | grep "$ERROR_MESSAGE" | awk -F 'neqt ' '{print $2}' | tr -d '()' | sort -u)

if [ -z "$neqt_numbers" ]; then
  echo "No error detected!"
  exit 0
fi

# Initialize output
echo -e "Ext\tType\tName"

# Loop through each unique neqt number
for neqt in $neqt_numbers; do
  # Get the info from eqstat
    eqstat_output=$(tool eqstat n "$neqt")

  # Extract the info from eqstat
    dir_nb=$(echo "$eqstat_output" | egrep '[0-9]{5}' | cut -d\| -f6 | sed 's/ //g')
    typ_term=$(echo "$eqstat_output" | egrep '[0-9]{5}' | cut -d\| -f5 | sed 's/ //g')

  # Extract the name from the database
    name=$(echo "select disp_name from POSTE where numan='$dir_nb';" | cuser | egrep "\-\-> '" | cut -d\' -f2)


  # Display it all
    echo -e "$dir_nb\t$typ_term\t$name"

done
