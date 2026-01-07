#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# This script shows detailed information about any active calls in Asterisk.
#
# Inputs / Behavior:
# - Clears the terminal before displaying information.
# - Uses "asterisk -rx "core show channels verbose"" to list active calls with details.
# - Displays a message if no active calls are present.
# - Waits for the user to press Enter before exiting.
# ------------

source ./input_validation.sh

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

# Clear the terminal
clear

# Function to check active calls with details
check_active_calls() {
    echo -e "\033[44m\033[1;33m========================\033[0m"
    echo -e "\033[44m\033[1;33m    Active Calls       \033[0m"
    echo -e "\033[44m\033[1;33m========================\033[0m"

    # Check active calls using Asterisk command with detailed information
    active_calls=$(asterisk -rx "core show channels verbose")

    # Display results
    if [[ "$active_calls" == *"No active channels"* ]]; then
        echo "No active calls currently."
    else
        echo "$active_calls"
    fi
}

# Call the function to check active calls
check_active_calls

# Wait for user input before exiting
read -p "Press [Enter] to return to the menu..."

