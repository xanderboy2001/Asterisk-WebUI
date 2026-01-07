#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# Replaces a phone in Asterisk by updating its MAC address.
#
# Inputs / Expectations:
# - Prompts interactively for old MAC or extension and new MAC.
# - Uses /etc/asterisk/sip.conf, extensions.conf, and /var/lib/tftpboot.
# - Requires write access to config files and TFTP directory.
#
# Behavior:
# - Backs up sip.conf and extensions.conf.
# - Deletes the old .cnf.xml file for the phone.
# - Creates a new .cnf.xml file from SEP0000000.cnf.xml template.
# - Updates SIP and extensions configuration with new MAC (SEP-prefixed).
# - Reloads Asterisk dialplan, SIP, and voicemail configurations.
# ------------

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

# Define file paths
EXTENSIONS_CONF="/etc/asterisk/extensions.conf"
SIP_CONF="/etc/asterisk/sip.conf"
TFTPBOOT_DIR="/var/lib/tftpboot"
BACKUP_DIR="/etc/asterisk/backup"

# Check if backup directory exists; if not, create it
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Backup the configuration files
cp "$EXTENSIONS_CONF" "$BACKUP_DIR/extensions.conf.bak_$(date +%F_%T)"
cp "$SIP_CONF" "$BACKUP_DIR/sip.conf.bak_$(date +%F_%T)"

# Function to create the new .cnf.xml file
create_new_cnf() {
    local new_mac=$1
    local extension=$2

    # Check if template file exists
    if [[ -f "$TFTPBOOT_DIR/SEP0000000.cnf.xml" ]]; then
        cp -v "$TFTPBOOT_DIR/SEP0000000.cnf.xml" "$TFTPBOOT_DIR/SEP${new_mac}.cnf.xml"
        sed -i "s/--SEPMAC--/SEP${new_mac}/" "$TFTPBOOT_DIR/SEP${new_mac}.cnf.xml"
        sed -i "s/--EXTENNUMBER--/${extension}/" "$TFTPBOOT_DIR/SEP${new_mac}.cnf.xml"
        echo "Created new .cnf.xml file for SEP${new_mac}."
    else
        echo "Template file SEP0000000.cnf.xml not found in $TFTPBOOT_DIR."
        exit 1
    fi
}

# Ask the user for old Mac or extension
read -p "Would you like to search by (e)xtension or (m)ac address? [e/m]: " choice

if [[ "$choice" == "e" ]]; then
    # Prompt for the extension number
    read -p "Enter the extension number: " extension
    mac_address_clean=$(grep -B1 "callerid=.*<${extension}>" "$SIP_CONF" | grep -oP 'SEP\K\w+')

    if [[ -z "$mac_address_clean" ]]; then
        echo "No corresponding MAC address found for extension $extension."
        exit 1
    fi

elif [[ "$choice" == "m" ]]; then
    # Prompt for the old MAC address
    read -p "Enter the Old MAC address (in format AA:BB:CC:DD:EE:FF or AABBCCDDEEFF): " mac_address
    mac_address_clean=${mac_address//:/}

    # Find the corresponding extension number in sip.conf
    extension=$(grep -A3 "\[SEP$mac_address_clean\]" "$SIP_CONF" | grep -oP 'callerid=".*" <\K\d+')

    if [[ -z "$extension" ]]; then
        echo "No corresponding extension found for MAC address SEP$mac_address_clean."
        exit 1
    fi
else
    echo "Invalid choice. Please select either 'e' for extension or 'm' for MAC address."
    exit 1
fi

# Delete the old .cnf.xml file
old_cnf_file="$TFTPBOOT_DIR/SEP${mac_address_clean}.cnf.xml"
if [[ -f "$old_cnf_file" ]]; then
    rm -f "$old_cnf_file"
    echo "Deleted old .cnf.xml file for SEP${mac_address_clean}."
else
    echo "No old .cnf.xml file found for SEP${mac_address_clean}."
fi

# Prompt for the new MAC address
read -p "Enter the new MAC address (in format AA:BB:CC:DD:EE:FF or AABBCCDDEEFF): " new_mac
new_mac_address_clean=${new_mac//:/}

# Create the new .cnf.xml file
create_new_cnf "$new_mac_address_clean" "$extension"

# Replace instances of the old MAC address with the new MAC address in sip.conf and extensions.conf
sed -i "s/SEP${mac_address_clean}/SEP${new_mac_address_clean}/g" "$SIP_CONF"
sed -i "s/SEP${mac_address_clean}/SEP${new_mac_address_clean}/g" "$EXTENSIONS_CONF"

echo "Updated sip.conf and extensions.conf with new MAC address."
echo "Operation completed."
asterisk -x 'dialplan reload'
asterisk -x 'voicemail reload'
asterisk -x 'sip reload'
