#!/usr/bin/env bash
set -e
set -o pipefail
set -u
[[ -n "${DEBUG:-}" ]] && set -x
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"


echo $__base
