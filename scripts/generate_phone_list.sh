#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# Lists all active SIP extensions and their CallerID names from sip.conf.
#
# Inputs / Expectations:
# - Uses /etc/asterisk/sip.conf.
# - Requires read access to the file.
#
# Behavior:
# - Parses each SIP section ([<extension>]) for a callerid field.
# - Prints the extension number and CallerID name in a table format.
# - Handles all entries sequentially; ignores sections without callerid.
# ------------

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

# Define the path to sip.conf
SIP_CONF="/etc/asterisk/sip.conf"

# Initialize output header
echo "Extension | CallerID Name"
echo "----------------------------"

# Variables to temporarily hold phone details
callerid=""

# Parse sip.conf and extract only callerid information
while IFS= read -r line; do
    # Detect the start of a phone section
    if [[ $line =~ ^\[.*\] ]]; then
        # If a previous phone was read, display it
        if [ ! -z "$callerid" ]; then
            # Extract name and number from callerid in the format "Name <Number>"
            name=$(echo "$callerid" | sed 's/<.*//')    # Extract name part
            number=$(echo "$callerid" | sed 's/.*<//;s/>//')  # Extract number part
            echo "$number | $name"
        fi
        
        # Reset callerid field for the new section
        callerid=""
    fi
    
    # Extract the callerid field if it exists
    if [[ $line =~ ^callerid=(.*) ]]; then
        callerid="${BASH_REMATCH[1]}"
    fi
done < "$SIP_CONF"

# Output the last phone entry to the terminal
if [ ! -z "$callerid" ]; then
    # Extract name and number from callerid in the format "Name <Number>"
    name=$(echo "$callerid" | sed 's/<.*//')
    number=$(echo "$callerid" | sed 's/.*<//;s/>//')
    echo "$number | $name"
fi

echo "----------------------------"

