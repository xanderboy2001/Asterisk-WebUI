#!/usr/bin/env bash
set -euo pipefail

# --- HELP ---
# Executes the Python script to reboot a single phone managed by Asterisk.
#
# Inputs / Expectations:
# - Runs /var/lib/asterisk/scripts/reboot_phone.py using python3.
# - Requires Python 3 and sufficient permissions to reboot phones.
#
# Behavior:
# - Simply calls the Python script; all logic is handled there.
# ------------

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi

python3 /var/lib/asterisk/scripts/reboot_phone.py
