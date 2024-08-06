#!/bin/bash

declare -A dc_map
dc_map["172.16.0.0/19"]="EUBKP01"
dc_map["172.18.128.0/18"]="FRDUN03"
dc_map["172.18.192.0/18"]="FRCRX01"
dc_map["172.19.0.0/18"]="DEFRA01"
dc_map["172.19.64.0/18"]="CAMTL01"
dc_map["172.19.128.0/18"]="USWDC01"
dc_map["172.19.192.0/18"]="USPOR01"
dc_map["172.20.0.0/18"]="FRDUN02"
dc_map["172.20.64.0/18"]="FRSBG02"
dc_map["172.26.0.0/16"]="TX1"
dc_map["172.29.0.0/18"]="FRSBG01"

if [ "$#" -ne 1 ]; then
    echo "./reload_dns.sh <DATACENTER>"
    exit 1
fi

dc_name="$1"

found=0
for ip_range in "${!dc_map[@]}"; do
    if [ "${dc_map[$ip_range]}" == "$dc_name" ]; then
        /root/tools/admin_tools/venv_admin_tools/bin/python /root/tools/admin_tools/inventaire-netbox/create_dns_entries_from_netbox.py -d $ip_range
        found=1
        break
    fi
done

if [ $found -eq 0 ]; then
    echo "Datacenter '$dc_name' not found."
    exit 1
fi
