{% import_json 'data/main.json' as data %}
{% set domain = data.network.domain %}
{% set host = grains["host"] %}

{% set is_proxmox_node = host is match('n\d-cls\d') %}
{% set is_vm = host in data.proxmox_vms | map(attribute='vm_name') %}

{% if is_proxmox_node %}
{{ host }}_network_conf:
  file.managed:
    - name: /etc/systemd/network/10-eth0.network
    - source: salt://global/common/networkd/files/networkd-conf
    - template: jinja
    - context:
        netmask: {{ data.network.netmask }}
        gateway: {{ data.network.gateway }}
        main_iface: {{ data.proxmox_nodes[host].main_iface }}
        ip_addr: {{ data.proxmox_nodes[host].ip_addr }}
        dns_nameservers: {{ data.network.dns_nameservers }}

{% elif is_vm %}
{{ host }}_network_conf:
  file.managed:
    - name: /etc/systemd/network/10-eth0.network
    - source: salt://global/common/networkd/files/networkd-conf
    - template: jinja
    - context:
        netmask: {{ data.network.netmask }}
        gateway: {{ data.network.gateway }}
        main_iface: {{ (data.proxmox_vms | selectattr('vm_name', 'equalto', host) | first).main_iface }}
        ip_addr: {{ (data.proxmox_vms | selectattr('vm_name', 'equalto', host) | first).ip_addr }}
        dns_nameservers: {{ data.network.dns_nameservers }}

{% else %}
network_conf_absent_warning:
  test.show_notification:
    - text: "COMPLETE THE NETWORK CONFIGURATION FOR {{ host }} IN DATA/MAIN.JSON"
{% endif %}
