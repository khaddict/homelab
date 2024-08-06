#!/bin/bash

SNAPSHOT_NAME="auto_snapshot_$(date +%Y%m%d_%H%M%S)"

NODES=("n1-cls1" "n2-cls1" "n3-cls1")

for NODE in "${NODES[@]}"; do
    # VMID > 200 = templates
    VM_IDS=$(pvesh get /nodes/$NODE/qemu --output-format json | jq -r '.[] | select(.vmid < 200) | .vmid')
    for VMID in $VM_IDS; do
        pvesh create /nodes/$NODE/qemu/$VMID/snapshot --snapname $SNAPSHOT_NAME --description "Automated snapshot" --vmstate true
    done
done
