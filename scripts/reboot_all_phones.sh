#!/usr/bin/env bash
set -euo pipefail

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"

# --- HELP ---
# Executes the Python script to reboot all phones managed by Asterisk.
#
# Inputs / Expectations:
# - Runs /var/lib/asterisk/scripts/reboot_all_phones.py using python3.
# - Requires Python 3 and sufficient permissions to reboot phones.
#
# Behavior:
# - Simply calls the Python script; all logic is handled there.
# ------------

source ${__dir}/input_validation.sh

if [[ "${TESTING:-0}" == "1" ]]; then
	echo "[TEST MODE]"
	echo "Script: $0"
	echo "Arguments: $*"
	exit 0
fi
python3 /var/lib/asterisk/scripts/reboot_all_phones.py
