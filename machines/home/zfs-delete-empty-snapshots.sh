#!/usr/bin/env bash

opts=$(getopt -o d: --long dataset: -n 'zfs-delete-empty-snapshots' -- "$@")

exit_code=$?

if [ ${exit_code} -ne 0 ]; then
    exit ${exit_code}
fi

eval set -- "$opts"

while true; do
    case "$1" in
    -d | --dataset)
        case "$2" in
        "") shift 2 ;;
        *)
            dataset=$2
            shift 2
            ;;
        esac
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Internal error!"
        exit 1
        ;;
    esac
done

fail() {
    printf '%s\n' "$1" >&2
    exit "${2-1}"
}

if [[ ! -v dataset ]]; then
    fail "Missing required --dataset parameter"
fi

mapfile -t datasets < <(zfs list -Hr -t snapshot "${dataset}" | grep '@' | cut -d '@' -f 1 | uniq)

for dataset in "${datasets[@]}"; do
    # Changed to now sort newest to oldest.  This will mean that newer snapshots without deltas will get removed.
    mapfile -t empty_snapshots < <(zfs list -Hr -d1 -t snapshot -o name,used -S creation "${dataset}" | sed '$d' | awk ' $2 == "0B" { print $1 }')
    for empty_snapshot in "${empty_snapshots[@]}"; do

        # Added safety check.  Verify the size of the snapshot prior to destroying it
        used=$(zfs list -Hr -d1 -t snapshot -o used "${empty_snapshot}")
        if [[ $used != "0B" ]]; then
            continue
        fi

        echo "Destroying empty snapshot ${empty_snapshot}"
        zfs destroy "${empty_snapshot}"
    done
done
