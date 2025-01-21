{% import_json 'data/main.json' as data %}
{% set domain = data.network.domain %}
{% set host = grains["host"] %}

{% set is_proxmox_node = host is match('n\d-cls\d') %}
{% set is_vm = host in data.proxmox_vms | map(attribute='vm_name') %}

{% if is_proxmox_node %}
{{ host }}_network_conf:
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://global/common/network/files/network-conf-proxmox
    - template: jinja
    - context:
        netmask: {{ data.network.netmask }}
        gateway: {{ data.network.gateway }}
        main_iface: {{ data.proxmox_nodes[host].main_iface }}
        ip_addr: {{ data.proxmox_nodes[host].ip_addr }}

{% elif is_vm %}
{{ host }}_network_conf:
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://global/common/network/files/network-conf
    - template: jinja
    - context:
        netmask: {{ data.network.netmask }}
        gateway: {{ data.network.gateway }}
        main_iface: {{ (data.proxmox_vms | selectattr('vm_name', 'equalto', host) | first).main_iface }}
        ip_addr: {{ (data.proxmox_vms | selectattr('vm_name', 'equalto', host) | first).ip_addr }}

{% else %}
network_conf_absent_warning:
  test.show_notification:
    - text: "COMPLETE THE NETWORK CONFIGURATION FOR {{ fqdn }} IN DATA/MAIN.JSON"
{% endif %}
