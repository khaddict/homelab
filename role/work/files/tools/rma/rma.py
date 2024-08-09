#!/usr/bin/python3

import requests
from tabulate import tabulate
import pynetbox
import argparse
import json
from concurrent.futures import ThreadPoolExecutor, as_completed

NETBOX_URL = "https://netbox.blade.sh/"
INVENTORY_URL = "https://inventory.blade.sh/server"
GAP_DMM_URL = "http://gap-dmm.{datacenter}.blade-group.net"

def get_rma_data(datacenter, pool):
    """Fetch RMA data for a given datacenter and pool."""
    rma_url = f"{GAP_DMM_URL.format(datacenter=datacenter)}/servers/rma" if pool == "all" else f"{GAP_DMM_URL.format(datacenter=datacenter)}/servers/rma/{pool}"

    response = requests.get(rma_url)
    if response.status_code == 200:
        data = response.json()
        for item in data:
            item['datacenter'] = datacenter.upper()
            item['pool'] = pool.upper()
        return data
    else:
        print(f"Failed to fetch RMA data for {datacenter} and pool {pool}")
        return []

def fetch_netbox_url(netbox_api, hostname):
    """Fetch NetBox URL for a given hostname."""
    try:
        device = netbox_api.dcim.devices.get(q=hostname)
        if device:
            return f"{NETBOX_URL}dcim/devices/{device.id}"
        return "N/A"
    except Exception as e:
        print(f"Error fetching NetBox URL for {hostname}: {e}")
        return "N/A"

def fetch_tickets(dmm_url, hostname):
    """Fetch tickets for a given hostname."""
    try:
        response = requests.get(f"{dmm_url}/server/{hostname}/tickets")
        if response.status_code == 200:
            tickets = response.json()
            return tickets if isinstance(tickets, list) else ["No tickets"]
        else:
            return ["No tickets"]
    except Exception as e:
        print(f"Error fetching tickets for {hostname}: {e}")
        return ["No tickets"]

def fetch_boot(dmm_url, hostname):
    """Fetch boot configuration for a given hostname."""
    try:
        response = requests.get(f"{dmm_url}/server/{hostname}/boot")
        if response.status_code == 200:
            boot = response.json()
            if isinstance(boot, dict) and 'conf' in boot and 'server' in boot:
                return f"{boot['conf']} | {boot['server']}"
            else:
                print(f"Unexpected boot data structure for {hostname}: {boot}")
                return "N/A"
        else:
            print(f"Failed to fetch boot data for {hostname}")
            return "N/A"
    except Exception as e:
        print(f"Error fetching boot data for {hostname}: {e}")
        return "N/A"

def create_table_data(data, netbox_api, inventory_url):
    """Create table data from sorted RMA data using parallel requests."""
    table_data = []
    with ThreadPoolExecutor(max_workers=15) as executor:
        futures = {}

        for item in data:
            hostname = item['hostname']
            datacenter = item['datacenter']
            pool = item['pool']
            dmm_url = GAP_DMM_URL.format(datacenter=datacenter)

            futures[executor.submit(fetch_boot, dmm_url, hostname)] = (hostname, 'boot')
            futures[executor.submit(fetch_netbox_url, netbox_api, hostname)] = (hostname, 'netbox')
            futures[executor.submit(fetch_tickets, dmm_url, hostname)] = (hostname, 'tickets')

        results = {hostname: {'boot': 'N/A', 'netbox': 'N/A', 'tickets': ['No tickets']} for hostname in [item['hostname'] for item in data]}

        for future in as_completed(futures):
            hostname, data_type = futures[future]
            try:
                results[hostname][data_type] = future.result()
            except Exception as e:
                print(f"Error fetching {data_type} data for {hostname}: {e}")

        for idx, item in enumerate(data):
            hostname = item['hostname']
            datacenter = item['datacenter']
            pool = item['pool']
            table_data.append([
                idx + 1,
                datacenter,
                pool,
                hostname,
                results[hostname]['boot'],
                results[hostname]['netbox'],
                item.get('rma_notes', 'N/A'),
                results[hostname]['tickets'],
                f"{inventory_url}/{hostname}"
            ])

    sorted_table_data = sorted(table_data, key=lambda x: (x[1], x[6]))
    return sorted_table_data

def print_hostnames_by_ids(table_data):
    """Prompt user to select hostnames by IDs and generate Slack commands."""
    datacenters = {row[1].lower() for row in table_data}

    while True:
        commands = {dc: [] for dc in datacenters}
        user_input = input("\nEnter IDs separated by spaces (or 'q' to quit): ").strip()
        if user_input.lower() == 'q':
            break
        try:
            ids = [int(id_str.strip()) for id_str in user_input.split(' ') if id_str.strip().isdigit()]
        except ValueError:
            print("Invalid input. Please enter a list of IDs separated by spaces.")
            continue

        for id in ids:
            if 0 < id <= len(table_data):
                row = table_data[id - 1]
                datacenter = row[1].lower()
                hostname = row[3]
                commands[datacenter].append(hostname)

        for dc, hostnames in commands.items():
            if hostnames:
                hostnames_str = ",".join(hostnames)
                print(f"\nType this command on Slack:\n.{dc} st2 back_toprod {hostnames_str}")

def main(data_dict):
    """Main function to fetch and display RMA data."""
    netbox_api = pynetbox.api(NETBOX_URL, token="{{ netbox_token_ro }}")

    headers = ["ID", "DATACENTER", "POOL", "HOSTNAME", "BOOT", "NETBOX", "RMA NOTE", "TICKETS", "BLADE INVENTORY"]
    all_data = []

    for datacenter, pools in data_dict.items():
        for pool in pools:
            data = get_rma_data(datacenter, pool)
            all_data.extend(data)

    sorted_data = sorted(all_data, key=lambda x: (x.get('datacenter'), x.get('rma_notes')))
    table_data = create_table_data(sorted_data, netbox_api, INVENTORY_URL)

    print(tabulate(table_data, headers=headers, tablefmt="grid"))
    print_hostnames_by_ids(table_data)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--data', type=str, help="[REQUIRED] JSON dictionary of the datacenters and pools you want (you can get all pools with pool = all) : '{\"datacenter\": [\"pool1\", \"pool2\", ...]}'. Example: '{\"frdun02\": [\"pool-a4500\", \"pool-p5000\"], \"uswdc01\": [\"all\"]}'", required=True)
    args = parser.parse_args()

    try:
        data_dict = json.loads(args.data)
    except json.JSONDecodeError:
        print("Invalid JSON format for data argument.")
        exit(1)

    main(data_dict)
