#!/usr/bin/env bash
set -euo pipefail

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"

# --- HELP ---
# Removes a phone or extension from Asterisk configuration files.
#
# Inputs / Expectations:
# - Prompts interactively to choose removal by extension or MAC address.
# - Uses /etc/asterisk/extensions.conf, sip.conf, voicemail.conf, and /var/lib/tftpboot.
# - Requires write access to these files and backup directory (/etc/asterisk/backup).
# - Requires Asterisk CLI access to reload dialplan, SIP, and voicemail.
#
# Behavior:
# - Backs up extensions.conf, sip.conf, and voicemail.conf before making changes.
# - Deletes extension lines and associated voicemail entries when removing by extension.
# - Deletes SIP configuration, dialplan references, voicemail entries, and XML files when removing by MAC.
# - Cleans up multi-device lines and leftover formatting in extensions.conf.
# - Reloads Asterisk dialplan, SIP, and voicemail configurations after removal.
# ------------

source ./input_validation.sh

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

# Define file paths
EXTENSIONS_CONF="/etc/asterisk/extensions.conf"
SIP_CONF="/etc/asterisk/sip.conf"
VOICEMAIL_CONF="/etc/asterisk/voicemail.conf"
TFTPBOOT_DIR="/var/lib/tftpboot"
BACKUP_DIR="/etc/asterisk/backup"

# Check if backup directory exists; if not, create it
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Backup the configuration files
cp "$EXTENSIONS_CONF" "$BACKUP_DIR/extensions.conf.bak_$(date +%F_%T)"
cp "$SIP_CONF" "$BACKUP_DIR/sip.conf.bak_$(date +%F_%T)"
cp "$VOICEMAIL_CONF" "$BACKUP_DIR/voicemail.conf.bak_$(date +%F_%T)"

# Ask the user to choose between extension or MAC address
read -p "Would you like to search by (e)xtension or (m)ac address? [e/m]: " choice

if [[ "$choice" == "e" ]]; then
    # Prompt for the extension number
    read -p "Enter the extension number: " extension
    
    # Remove the extension and voicemail entries associated with the extension
    sed -i "/^exten => $extension,/d" "$EXTENSIONS_CONF"
    sed -i "/^$extension\s*=/d" "$VOICEMAIL_CONF"
    echo "Removed extension $extension and associated voicemail entry."

elif [[ "$choice" == "m" ]]; then
    # Prompt for the MAC address
    read -p "Enter the MAC address (e.g., 5CE17611738E): " sep_mac

    # Remove lines where the MAC is the only device in the extensions.conf
    sed -i "/Dial(SIP\/SEP$sep_mac,.*)/d" "$EXTENSIONS_CONF"

    # Remove only the specified MAC part from lines with multiple devices in extensions.conf
    sed -i "s/SIP\/SEP$sep_mac//g" "$EXTENSIONS_CONF"

    # Clean up any leftover '&' characters after removal in extensions.conf
    sed -i "s/&&/&/g; s/&$//g" "$EXTENSIONS_CONF"

    # Remove the configuration for the MAC in sip.conf, ensuring complete block removal
    sed -i "/\[SEP$sep_mac\]/,/\[/d" "$SIP_CONF"
    echo "Removed configuration for SEP$sep_mac from $SIP_CONF."
    
    # Remove the corresponding XML file from /var/lib/tftpboot
    xml_file="$TFTPBOOT_DIR/SEP${sep_mac}.cnf.xml"
    if [ -f "$xml_file" ]; then
        rm -f "$xml_file"
        echo "Deleted $xml_file."
    else
        echo "No XML configuration file found for SEP$sep_mac in $TFTPBOOT_DIR."
    fi

    # Optionally, remove any voicemail entry associated with this MAC address if linked to an extension
    extension=$(grep -B1 "SIP/SEP$sep_mac" "$EXTENSIONS_CONF" | grep -oP '^exten => \K\d+' | head -n 1)
    if [ ! -z "$extension" ]; then
        sed -i "/^$extension\s*=/d" "$VOICEMAIL_CONF"
        echo "Removed voicemail entry for extension $extension associated with SEP$sep_mac."
    fi

else
    echo "Invalid choice. Please select either 'e' for extension or 'm' for MAC address."
    exit 1
fi

echo "Operation completed."


asterisk -x 'dialplan reload'
asterisk -x 'voicemail reload'
asterisk -x 'sip reload'

