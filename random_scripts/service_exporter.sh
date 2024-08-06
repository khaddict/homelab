#!/bin/bash

# The prometheus-node-exporter doesn't work with inactive services (only for failed ones).
# Not used for the moment

active_count=0
inactive_count=0
failed_count=0

while IFS= read -r line; do
    service_name=$(echo "$line" | awk '{print $1}')
    service_status=$(echo "$line" | awk '{print $3}')

    if [[ "$service_name" && "$service_name" != "UNIT" ]]; then
        case "$service_status" in
            active)
                ((active_count++))
                echo "service_status{service=\"$service_name\"} 1"
                ;;
            inactive)
                ((inactive_count++))
                echo "service_status{service=\"$service_name\"} 0"
                ;;
            failed)
                ((failed_count++))
                echo "service_status{service=\"$service_name\"} -1"
                ;;
            *)
                continue
                ;;
        esac
    fi
done < <(systemctl list-units --type=service --all --no-pager --no-legend)

echo "# HELP active_services_total Total number of active services."
echo "# TYPE active_services_total gauge"
echo "active_services_total $active_count"

echo "# HELP inactive_services_total Total number of inactive services."
echo "# TYPE inactive_services_total gauge"
echo "inactive_services_total $inactive_count"

echo "# HELP failed_services_total Total number of failed services."
echo "# TYPE failed_services_total gauge"
echo "failed_services_total $failed_count"
