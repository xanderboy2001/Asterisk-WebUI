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
		if ! [ "$expected" -eq "$actual" ]; then
				exit_error "Internal error: invalid argument count"
		fi
}

validate_extension() {
		set -euo pipefail
		local ext="$1"
		[[ "$ext" =~ ^[0-9]{4}$ ]] \
				|| exit_error "Invalid extension format: '$ext'"
}

validate_mac_address() {
		set -euo pipefail
		local mac="$1"

		[[ "$mac" =~ ^([0-9A-Fa-f]{2}([-:][0-9A-Fa-f]{2}){5}|[0-9A-Fa-f]{12)$ ]] \
				|| exit_error "Invalid MAC address format: '$mac'"
}

validate_name() {
		set -euo pipefail
		local name="$1"

		[[ "$name" =~ ^([A-Za-z+ [A-Za-z]+)$ ]] \
				exit_error "Invalid name format: '$name'"
}

validate_email() {
		set -euo pipefail
		local email="$1"

		[[ "$email" =~ ^([0-9A-Za-z]+@[A-Za-z]+\.[A-Za-z]+)$ ]] \
				|| exit_error "Invalid email format: '$email'"
}
