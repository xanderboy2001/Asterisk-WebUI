#!/usr/bin/env bash
set -euo pipefail

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"

# --- HELP ---
# This script lists all SIP devices that currently have an unknown status in Asterisk.
#
# Inputs / Behavior:
# - Clears the terminal for readability.
# - Uses the Asterisk CLI command `sip show peers` to get all SIP devices.
# - Filters and displays only devices with status "UNKNOWN".
# - Prints a message if no devices have unknown status.
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

# Function to show SIP devices with unknown status
show_unknown_sip_devices() {
    echo -e "\033[44m\033[1;33m========================\033[0m"
    echo -e "\033[44m\033[1;33m   SIP Devices with Unknown Status  \033[0m"
    echo -e "\033[44m\033[1;33m========================\033[0m"

    # Get the list of SIP peers and filter for unknown status
    unknown_devices=$(asterisk -rx "sip show peers" | grep 'UNKNOWN' | awk '{print $1}')

    # Check if there are any devices with unknown status
    if [ -z "$unknown_devices" ]; then
        echo "No SIP devices are currently in unknown status."
    else
        echo "The following SIP devices have an unknown status:"
        echo "$unknown_devices"
    fi
}

# Call the function to show SIP devices with unknown status
show_unknown_sip_devices

# Wait for user input before exiting
read -p "Press [Enter] to return to the menu..."

