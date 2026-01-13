#!/usr/bin/env bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"

exit_error() {
		echo >&2 "$@"
		return 1
}

check_nro_args() {
		set -euo pipefail

		local expected=""
		local actual=""

		while (($#)); do
				case "$1" in
						--expected)
								expected="$2"
								shift 2
								;;
						--actual)
								actual="$2"
								shift 2
								;;
						*)
								exit_error "${FUNCNAME[0]}: unexpected option $1"
								;;
				esac
		done

		# Check that we actually received both arguments
		[ -n "${expected:-}" ] \
				|| exit_error "${FUNCNAME[0]}: --expected is required"
		[ -n "${actual:-}" ] \
				|| exit_error "${FUNCNAME[0]}: --actual is required"


		# Make sure both arguments are positive
		if [ "$expected" -lt 0 ] || [ "$actual" -lt 0 ]; then
				exit_error "Both arguments must be greater than 0"
		fi

		# Set error message. If 1, use singular noun, if more than 1, use plural
		error_msg=''
		if [ "$expected" -eq 1 ]; then
				error_msg="$expected argument required, $actual provided"
		else
				error_msg="$expected arguments required, $actual provided"
		fi

		# Check if exptected matches actual
		if ! [ "$expected" -eq "$actual" ]; then
				exit_error "$error_msg"
		fi
}

validate_extension() {
		set -euo pipefail
		check_nro_args --expected 1 --actual $#
		echo "$1" | grep -E -q '^[0-9]{4}$' || exit_error "4-digit numeric argument required, '$1' provided"
}

validate_mac_address() {
		set -euo pipefail
		check_nro_args --expected 1 --actual $#
		echo "$1" | grep -E -q '^([0-9A-Fa-f]{12}|([0-9A-Fa-f]{2}([-:][0-9A-Fa-f]{2}){5}))$' \
				|| exit_error "MAC address required. Accepted formats are \"ab-cd-ef-01-23-45\". Received: $1"
}

validate_name() {
		set -euo pipefail
		check_nro_args --expected 1 --actual $#
		echo "$1" | grep -E -q '^[A-Za-z]+ [A-Za-z]+$' \
				|| exit_error "Name must be two alphabetic strings (e.g. 'John Smith'). Received $1"
}

validate_email() {
		set -euo pipefail
		check_nro_args --expected 1 --actual $#
		echo "$1" | grep -E -q '^[0-9A-Za-z]+@[A-Za-z]+\.[A-Za-z]+$' || echo "invalid"
}
