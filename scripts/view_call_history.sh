#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# This script displays the call log for a specified Asterisk extension.
#
# Inputs / Behavior:
# - Prompts the user for the extension number.
# - Reads the CDR CSV file located at /var/log/asterisk/cdr-csv/Master.csv.
# - Filters calls where the extension is either the source or destination.
# - Displays date/time, source, destination, duration, and call status.
# - Exits with a message if the CDR file is missing or no extension is provided.
# ------------

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

# Location of the Asterisk CDR CSV file
CDR_FILE="/var/log/asterisk/cdr-csv/Master.csv"

# Check if the file exists
if [[ ! -f $CDR_FILE ]]; then
    echo "CDR file not found: $CDR_FILE"
    exit 1
fi

# Prompt the user for an extension
read -p "Enter the extension number: " EXTENSION

# Check if the input is empty
if [[ -z "$EXTENSION" ]]; then
    echo "No extension provided. Exiting."
    exit 1
fi

# Display header for the output
echo "Call log for extension: $EXTENSION"
echo "Date/Time, Source, Destination, Duration, Disposition"

# Read the CDR CSV file and filter based on the extension
awk -F',' -v ext="$EXTENSION" '
{
    # Remove surrounding quotes from the fields if they exist
    gsub(/^\"|\"$/, "", $2);  # Remove quotes from src
    gsub(/^\"|\"$/, "", $3);  # Remove quotes from dst

    # Print debug info (optional)
    # print "Processing record: src=" $2 ", dst=" $3;

    # Filter records where the source or destination matches the extension
    if ($2 == ext || $3 == ext) {
        # Print the relevant fields correctly
        print $9 ", " $2 " -> " $3 ", Duration: " $10 "s, Status: " $12
    }
}' "$CDR_FILE"

