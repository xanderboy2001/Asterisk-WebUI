#!/usr/bin/env bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"

exit_error() {
		local msg="$1"
		local code="${2:-2}"
		echo >&2 "$msg"
		exit "$code"
}

check_nro_args() {
		set -euo pipefail

		local expected="$1"
		local actual="$2"

		# Make sure both arguments are positive
		if [ "$expected" -ne "$actual" ]; then
				echo >&2 "Internal error: expected $expected args, got $actual"
				return 2
		fi
}

validate_extension() {
		local ext="$1"

		if [[ ! "$ext" =~ ^[0-9]{4}$ ]]; then
				echo >&2 "Invalid extension format: '$ext'"
				return 1
		fi
}

validate_mac_address() {
		set -euo pipefail
		local mac="$1"

		if [[ ! "$mac" =~ ^([0-9A-Fa-f]{2}([-:][0-9A-Fa-f]{2}){5}|[0-9A-Fa-f]{12)$ ]]; then
				echo >&2 "Invalid MAC address format: '$mac'"
				return 1
		fi
}

validate_name() {
		local name="$1"

		if [[ ! "$name" =~ ^([A-Za-z+ [A-Za-z]+)$ ]]; then
				echo >&2 "Invalid name format: '$name'"
				return 1
		fi
}

validate_email() {
		local email="$1"

		if [[ ! "$email" =~ ^([0-9A-Za-z]+@[A-Za-z]+\.[A-Za-z]+)$ ]]; then
				echo >&2 "Invalid email format: '$email'"
				return 1
		fi
}
