#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# Displays a menu to open Asterisk configuration files in vim.
#
# Inputs / Expectations:
# - Prompts interactively to choose a file (sip.conf, extensions.conf, voicemail.conf).
# - Uses /etc/asterisk/{sip,extensions,voicemail}.conf.
# - Requires read access to the configuration files.
#
# Behavior:
# - Opens the selected file in vim if it exists.
# - Loops until the user chooses to quit.
# ------------

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

# Define file paths
SIP_CONF="/etc/asterisk/sip.conf"
EXTENSIONS_CONF="/etc/asterisk/extensions.conf"
VOICEMAIL_CONF="/etc/asterisk/voicemail.conf"

# Function to display the menu
display_menu() {
    echo "Asterisk Configuration File Menu:"
    echo "1. Open sip.conf"
    echo "2. Open extensions.conf"
    echo "3. Open voicemail.conf"
    echo "4. Quit"
}

# Main loop
while true; do
    display_menu

    # Get the user's choice
    read -p "Choose an option (1-4): " choice

    case $choice in
        1)
            # Open sip.conf in vim
            if [ -f "$SIP_CONF" ]; then
                vim "$SIP_CONF"
            else
                echo "$SIP_CONF not found."
            fi
            ;;
        2)
            # Open extensions.conf in vim
            if [ -f "$EXTENSIONS_CONF" ]; then
                vim "$EXTENSIONS_CONF"
            else
                echo "$EXTENSIONS_CONF not found."
            fi
            ;;
        3)
            # Open voicemail.conf in vim
            if [ -f "$VOICEMAIL_CONF" ]; then
                vim "$VOICEMAIL_CONF"
            else
                echo "$VOICEMAIL_CONF not found."
            fi
            ;;
        4)
            # Quit the script
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice, please select a valid option (1-4)."
            ;;
    esac
done

