#!/usr/bin/env bash
set -euo pipefail

exit_error() {
		echo >&2 "$@"
		exit 1
}

check_nro_args() {
		[ "$#" -eq 2 ] || exit_error "2 arguments required, $# provided"

		# $1 => nro arguments expected
		# $2 => nro arguments provided
		
		if [ "$1" -lt 1 ] || [ "$2" -lt 1 ]; then
				exit_error "Both arguments must be greater than 0"
		fi

		if [ "$1" -eq 1 ]; then
				error_msg="$1 argument required, $2 provided"
		else
				error_msg="$1 arguments required, $2 provided"
		fi

		if ! [ "$1" -eq "$2" ]; then
				exit_error "$error_msg"
		fi
}

validate_extension() {
		check_nro_args 1 $#
		echo "$1" | grep -E -q '^[0-9]{4}$' || exit_error "4-digit numeric argument required, $1 provided"
}

validate_mac_address() {
		check_nro_args 1 $#
		echo "$1" | grep -E -q '^([0-9A-Fa-f]{12}|([0-9A-Fa-f]{2}([-:][0-9A-Fa-f]{2}){5}))$' \
				|| exit_error "MAC address required. Accepted formats are \"ab-cd-ef-01-23-45\". Received: $1"
}

validate_name() {
		check_nro_args 1 $#
		echo "$1" | grep -E -q '^[A-Za-z]+ [A-Za-z]+$' \
				|| exit_err "Name must be two alphabetic strings (e.g. 'John Smith'). Received $1"
}

validate_email() {
		check_nro_args 1 $#
		echo "$1" | grep -E -q '^[0-9A-Za-z]+@[A-Za-z]+\.[A-Za-z]+$' || echo "invalid"
}
