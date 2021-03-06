#!/bin/bash

ABS_SCRIPT_PATH="$(dirname "$(readlink --canonicalize "${BASH_SOURCE[0]}")" )"
. "${ABS_SCRIPT_PATH}/../../common.sh"

SWAP_FILE="/dynamic_swapfile"
ALLOC_SIZE="8G"
MODE="mount"

function usage {
    cat << EndOfUsageMsg 
$0 : Mount swapfile

Usage: $0 [Option]
  Option:
    -f <file> Use a different file. (defualt: $SWAP_FILE)
    -s <size> Set swap size. (defualt: $ALLOC_SIZE)
    -r        Remove the added swap.
    -D        Debug flag.
    -h        This help msg.
EndOfUsageMsg
}

while getopts ":f:s:rDh" opt; do
case ${opt} in
    f ) SWAP_FILE=$OPTARG ;;
    s ) ALLOC_SIZE=$OPTARG ;;
    r ) MODE="remove" ;;
    D ) set -x ;;
    h ) usage; exit 0 ;;
    : ) echo "Invalid option: $OPTARG requires an argument" 1>&2 ; exit 1 ;;
    \? ) echo "Invalid Option: -$OPTARG" 1>&2 ; exit 1 ;;
esac done
shift $((OPTIND -1))

[[ $# -gt 0 ]] && usage && error "Positional arguments \"$*\" unsupported."

if [[ $MODE == "mount" ]]; then
    Detect_Mount=$(swapon --show=name | grep -c "${SWAP_FILE}" )
    [[ $Detect_Mount -ne 0 ]] && error "${SWAP_FILE} already mounted. Abort."
    try sudo fallocate -l "${ALLOC_SIZE}" "${SWAP_FILE}"
    try sudo chmod 600 "${SWAP_FILE}"
    try sudo mkswap "${SWAP_FILE}"
    try sudo swapon "${SWAP_FILE}"
else
    try sudo swapoff -v "${SWAP_FILE}"
    # sudo rm -i "${SWAP_FILE}"
fi