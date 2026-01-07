#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# Displays a menu of all scripts in the current directory and allows the user to run them.
#
# Inputs / Expectations:
# - Detects all .sh files in the same directory as this script.
# - Prompts interactively to select a script to run.
# - Requires execute permissions on the scripts.
#
# Behavior:
# - Lists scripts with numbered options and a quit choice.
# - Executes the selected script using bash.
# - Loops until the user chooses to quit.
# ------------

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

clear
BACKGROUND="\033[44m"  # Dark Blue Background
TEXT_COLOR="\033[1;33m"  # Bright Yellow Text
RESET="\033[0m"  # Reset

# Apply the colors
echo -e "${BACKGROUND}${TEXT_COLOR}"



# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Function to display the menu
display_menu() {
    echo -e "\n\033[1;34m========================\033[0m" # Blue header
    echo -e "\033[1;32m   Available Scripts    \033[0m" # Green title
    echo -e "\033[1;34m========================\033[0m"

    # List all .sh files in the directory
    sh_files=("$SCRIPT_DIR"/*.sh)
    
    if [ ${#sh_files[@]} -eq 0 ]; then
        echo -e "\033[1;31mNo .sh files found.\033[0m" # Red message
        exit 1
    fi

    # Display the list of scripts as menu options
    for i in "${!sh_files[@]}"; do
        script_name=$(basename "${sh_files[$i]}")
        echo -e "\033[1;36m$((i+1)). $script_name\033[0m" # Cyan option
    done

    echo -e "\033[1;33m$(( ${#sh_files[@]} + 1 )). Quit\033[0m" # Yellow quit option
}

# Main loop for the menu
while true; do
    display_menu

    # Get user's choice
    read -p "Choose an option (1-$(( ${#sh_files[@]} + 1 ))): " choice

    if [[ "$choice" -ge 1 && "$choice" -le "${#sh_files[@]}" ]]; then
        # Execute the chosen script
        echo -e "\n\033[1;32mRunning ${sh_files[$((choice-1))]}...\033[0m" # Green running message
        bash "${sh_files[$((choice-1))]}"
        echo
    elif [[ "$choice" -eq "$(( ${#sh_files[@]} + 1 ))" ]]; then
        # Exit the menu
        echo -e "\033[1;31mExiting...\033[0m" # Red exit message
        break
    else
        echo -e "\033[1;31mInvalid choice, please try again.\033[0m" # Red error message
    fi
done

