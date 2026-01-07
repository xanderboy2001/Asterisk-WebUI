#!/bin/bash

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

python3 /var/lib/asterisk/scripts/reboot_phone.py
