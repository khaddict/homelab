#!/bin/bash

SNAPSHOT_NAME="auto_snapshot_$(date +%Y%m%d_%H%M%S)"
NODES=("{{ host }}")

for NODE in "${NODES[@]}"; do
    # VMID > 200 = templates
    VMIDS=$(pvesh get /nodes/$NODE/qemu --output-format json | jq -r '.[] | select(.vmid < 200) | .vmid')
    for VMID in $VMIDS; do
        pvesh create /nodes/$NODE/qemu/$VMID/snapshot --snapname $SNAPSHOT_NAME --description "Automated snapshot" --vmstate true
        SNAPSHOTS=$(pvesh get /nodes/$NODE/qemu/$VMID/snapshot --output-format json | jq -r '.[].name' | sort -r)
        COUNT=0
        for SNAPSHOT in $SNAPSHOTS; do
            COUNT=$((COUNT+1))
            if [ $COUNT -gt 4 ]; then
                pvesh delete /nodes/$NODE/qemu/$VMID/snapshot/$SNAPSHOT
            fi
        done
    done
done
