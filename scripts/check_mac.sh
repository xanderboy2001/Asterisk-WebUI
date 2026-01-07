#!/bin/bash

# --- HELP ---
# Searches Asterisk and phone provisioning files for a specified MAC address.
#
# Inputs / Expectations:
# - Prompts interactively for a MAC address (e.g., SEPXXXXXXXXXXXX).
# - Uses /etc/asterisk/sip.conf and /etc/asterisk/extensions.conf.
# - Searches all *.cnf.xml files under /var/lib/tftpboot.
# - Read access to all files and directories is required.
#
# Behavior:
# - Exits with an error if any required file or directory is missing.
# - Reports each location where the MAC address is found.
#
# Notes:
# - Performs simple string matching; no validation or normalization of MAC format.
# ------------


SIP_CONF="/etc/asterisk/sip.conf"
CNF_XML_DIR="/var/lib/tftpboot"
EXTENSIONS_CONF="/etc/asterisk/extensions.conf"

# Check if the sip.conf file exists
if [ ! -f "$SIP_CONF" ]; then
    echo "Error: $SIP_CONF not found."
    exit 1
fi

# Check if the directory containing .cnf.xml files exists
if [ ! -d "$CNF_XML_DIR" ]; then
    echo "Error: Directory $CNF_XML_DIR not found."
    exit 1
fi

# Check if the extensions.conf file exists
if [ ! -f "$EXTENSIONS_CONF" ]; then
    echo "Error: $EXTENSIONS_CONF not found."
    exit 1
fi

# Ask the user for the MAC address to check
read -p "Enter the MAC address you want to check (format: SEPXXXXXXXXXXXX): " mac_address

# Check if the MAC address is present in the sip.conf file
if grep -q "$mac_address" "$SIP_CONF"; then
    echo "Phone with MAC address $mac_address is already in use in $SIP_CONF."
else
    echo "Phone with MAC address $mac_address is not in use in $SIP_CONF."
fi


# Now search for any extensions related to the MAC address in extensions.conf
if grep -q "$mac_address" "$EXTENSIONS_CONF"; then
    echo "The phone with MAC address $mac_address is referenced in $EXTENSIONS_CONF."
else
    echo "No reference to the phone with MAC address $mac_address found in $EXTENSIONS_CONF."
fi

# Check if the MAC address is present in any .cnf.xml files in the specified directory
cnf_xml_files=$(find "$CNF_XML_DIR" -name "*.cnf.xml")

found_in_xml=0
for file in $cnf_xml_files; do
    if grep -q "$mac_address" "$file"; then
        echo "Phone with MAC address $mac_address is in use in $file."
        found_in_xml=1
    fi
done

if [ $found_in_xml -eq 0 ]; then
    echo "Phone with MAC address $mac_address is not found in any .cnf.xml files."
fi
