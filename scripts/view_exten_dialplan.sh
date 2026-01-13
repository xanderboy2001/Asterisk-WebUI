#!/usr/bin/env bash
set -euo pipefail

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"

# --- HELP ---# This script displays the Asterisk dialplan for a specified extension in the default context.## Inputs / Behavior:# - Prompts the user to enter an extension number.# - Checks if the input is not empty.# - Uses the Asterisk CLI to retrieve the dialplan for the extension in the 'default' context.# - Displays the dialplan or a message if no dialplan exists for the extension.# - Waits for user input before exiting.# ------------

source ./input_validation.sh

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

# Clear the terminal
clear

# Function to show the dialplan for a specific extension in the default context
show_dialplan() {
    read -p "Enter the extension (e.g., 1234): " extension

    # Check if extension is not empty
    if [ -z "$extension" ]; then
        echo "No extension provided. Exiting..."
        exit 1
    fi

    echo -e "\033[44m\033[1;33m========================\033[0m"
    echo -e "\033[44m\033[1;33m    Dialplan for $extension in context 'default'   \033[0m"
    echo -e "\033[44m\033[1;33m========================\033[0m"

    # Show the dialplan for the specified extension in the default context
    dialplan_output=$(asterisk -rx "dialplan show $extension@default")
    
    # Display the output
    if [[ "$dialplan_output" == *"No such context"* ]]; then
        echo "No dialplan found for extension $extension in context 'default'."
    else
        echo "$dialplan_output"
    fi
}

# Call the function to show the dialplan
show_dialplan

# Wait for user input before exiting
read -p "Press [Enter] to return to the menu..."

