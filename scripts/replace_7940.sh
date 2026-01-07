#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# Replaces a phone in Asterisk by updating its MAC address and configuration files.
#
# Inputs / Expectations:
# - Prompts interactively for old MAC or extension and new MAC address.
# - Uses /etc/asterisk/sip.conf, extensions.conf, and /var/lib/tftpboot.
# - Requires write access to configuration files and TFTP boot directory.
# - Requires Asterisk CLI access to reload dialplan, SIP, and voicemail.
#
# Behavior:
# - Backs up sip.conf and extensions.conf before changes.
# - Deletes the old .cnf.xml/.cnf file for the phone.
# - Creates a new .cnf.xml file based on the template (SEP0000000.cnf.xml) with new MAC.
# - Updates SIP and extensions configuration to replace old MAC with new MAC (SEP-prefixed).
# - Reloads Asterisk dialplan, SIP, and voicemail configurations.
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
TFTPBOOT_DIR="/var/lib/tftpboot"
BACKUP_DIR="/etc/asterisk/backup"

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Backup configuration files
cp "$EXTENSIONS_CONF" "$BACKUP_DIR/extensions.conf.bak_$(date +%F_%T)"
cp "$SIP_CONF" "$BACKUP_DIR/sip.conf.bak_$(date +%F_%T)"

# Function to create a new .cnf.xml file
create_new_cnf() {
    local new_mac=$1
    local extension=$2

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

# User prompt to choose search by extension or MAC
read -p "Would you like to search by (e)xtension or (m)ac address? [e/m]: " choice

# Handle extension choice
if [[ "$choice" == "e" ]]; then
    read -p "Enter the extension number: " extension

    # Search for MAC address using awk
    mac_address_clean=$(awk -v ext="$extension" '
        BEGIN { IGNORECASE=1 }
        /callerid=.*<'"$extension"'>/ { getline; getline; if ($1 ~ /^\[/) { gsub(/[\[\]]/, "", $1); print $1 } }
    ' "$SIP_CONF")

    echo "Debug: Extracted MAC address for extension $extension: $mac_address_clean"

    if [[ -z "$mac_address_clean" ]]; then
        echo "No corresponding MAC address found for extension $extension in $SIP_CONF."
        exit 1
    fi

# Handle MAC choice
elif [[ "$choice" == "m" ]]; then
    read -p "Enter the Old MAC address (in format AA:BB:CC:DD:EE:FF or AABBCCDDEEFF): " mac_address
    mac_address_clean=${mac_address//:/}
    echo "Debug: Searching for extension with MAC address $mac_address_clean"

    # Find extension using awk
    extension=$(awk -v mac="$mac_address_clean" '
        BEGIN { IGNORECASE=1 }
        $0 ~ "\\[(SEP|SIP)" mac "\\]" { getline; getline; getline; if ($0 ~ /callerid/) { match($0, /<([0-9]+)>/, arr); print arr[1] } }
    ' "$SIP_CONF")

    echo "Debug: Extracted extension for MAC address $mac_address_clean: $extension"

    if [[ -z "$extension" ]]; then
        echo "No corresponding extension found for MAC address $mac_address_clean in $SIP_CONF."
        exit 1
    fi
else
    echo "Invalid choice. Please select either 'e' for extension or 'm' for MAC address."
    exit 1
fi

# Define prefix of old MAC for old .cnf.xml file path
old_cnf_prefix=""
if grep -q "\[SEP$mac_address_clean\]" "$SIP_CONF"; then
    old_cnf_prefix="SEP"
elif grep -q "\[SIP$mac_address_clean\]" "$SIP_CONF"; then
    old_cnf_prefix="SIP"
else
    echo "No entry with prefix SEP or SIP found for MAC address $mac_address_clean in $SIP_CONF."
    exit 1
fi
echo "Debug: Determined prefix for old MAC address is $old_cnf_prefix"

# Define old configuration file path based on prefix
if [[ "$old_cnf_prefix" == "SEP" ]]; then
    old_cnf_file="$TFTPBOOT_DIR/${old_cnf_prefix}${mac_address_clean}.cnf.xml"
elif [[ "$old_cnf_prefix" == "SIP" ]]; then
    old_cnf_file="$TFTPBOOT_DIR/${old_cnf_prefix}${mac_address_clean}.cnf"
fi
echo "Debug: Expected old configuration file path is $old_cnf_file"

# Delete the old .cnf.xml or .cnf file
if [[ -f "$old_cnf_file" ]]; then
    rm -f "$old_cnf_file"
    echo "Deleted old file: $old_cnf_file."
else
    echo "No old file found for ${old_cnf_prefix}${mac_address_clean} in $TFTPBOOT_DIR."
fi

# Prompt for new MAC address and clean format
read -p "Enter the new MAC address (in format AA:BB:CC:DD:EE:FF or AABBCCDDEEFF): " new_mac
new_mac_address_clean=${new_mac//:/}
echo "Debug: New MAC address clean format is $new_mac_address_clean"

# Create the new .cnf.xml file
create_new_cnf "$new_mac_address_clean" "$extension"

# Replace old MAC with new MAC in configuration files, ensuring SEP prefix
sed -i "s/\(${old_cnf_prefix}\)$mac_address_clean/SEP$new_mac_address_clean/g" "$SIP_CONF"
sed -i "s/\(${old_cnf_prefix}\)$mac_address_clean/SEP$new_mac_address_clean/g" "$EXTENSIONS_CONF"
echo "Updated $SIP_CONF and $EXTENSIONS_CONF with new MAC address: SEP$new_mac_address_clean"

echo "Script completed successfully."


asterisk -x 'dialplan reload'
asterisk -x 'voicemail reload'
asterisk -x 'sip reload'

