#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# Removes a phone from Asterisk SIP configuration and provisioning files.
#
# Inputs / Expectations:
# - Prompts interactively for a MAC address (AA:BB:CC:DD:EE:FF or AABBCCDDEEFF).
# - Uses /etc/asterisk/sip.conf and /var/lib/tftpboot for XML files.
# - Requires write access to sip.conf, backup directory, and TFTP boot directory.
#
# Behavior:
# - Backs up sip.conf to /etc/asterisk/backup before changes.
# - Deletes the SIP section corresponding to the MAC address (SEP<MAC>).
# - Deletes the corresponding .cnf.xml file if it exists.
# - Optionally reloads Asterisk if uncommented.
# ------------

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

# Define file paths
SIP_CONF="/etc/asterisk/sip.conf"
TFTPBOOT_DIR="/var/lib/tftpboot"
BACKUP_DIR="/etc/asterisk/backup"

# Check if backup directory exists; if not, create it
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Backup sip.conf before modifying it
cp $SIP_CONF $BACKUP_DIR/sip.conf.bak_$(date +%F_%T)

# Prompt the user for the MAC address
read -p "Enter the MAC address (in format AA:BB:CC:DD:EE:FF or AABBCCDDEEFF): " mac_address

# Format the MAC address to remove colons if necessary
mac_address_clean=${mac_address//:/}

# Check if the MAC address exists in sip.conf (as SEP<MAC_ADDRESS>)
if grep -q "\[SEP$mac_address_clean\]" $SIP_CONF; then
    echo "Found phone configuration for SEP$mac_address_clean in $SIP_CONF. Deleting..."

    # Delete the section for the MAC address in sip.conf
    sed -i "/\[SEP$mac_address_clean\]/,/^$/d" $SIP_CONF
    echo "Deleted phone configuration for SEP$mac_address_clean from $SIP_CONF."
else
    echo "No phone configuration found for MAC address SEP$mac_address_clean in $SIP_CONF."
fi

# Check if the corresponding XML file exists in /var/lib/tftpboot
xml_file="$TFTPBOOT_DIR/SEP${mac_address_clean}.cnf.xml"
if [ -f "$xml_file" ]; then
    echo "Found $xml_file. Deleting..."
    rm -f "$xml_file"
    echo "Deleted $xml_file."
else
    echo "No XML configuration file found for MAC address SEP$mac_address_clean in $TFTPBOOT_DIR."
fi

# Reload Asterisk configuration (optional, uncomment if needed)
# asterisk -rx "reload"

echo "Operation completed."

