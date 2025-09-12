{% import_json 'data/main.json' as data %}
{% set domain = data.network.domain %}
{% set host = grains["host"] %}

{% set is_proxmox_node = host is match('n\d-cls\d') %}
{% set is_vm = host in data.proxmox_vms | map(attribute='vm_name') %}

include:
{% if grains["os"] == "Debian" %}
  - base.systemd
  - base.systemd_resolved
{% elif grains["os"] == "Ubuntu" %}
  - base.systemd
{% endif %}

{% if is_proxmox_node %}
{{ host }}_networkd_conf:
  file.managed:
    - name: /etc/systemd/network/10-{{ data.proxmox_nodes[host].main_iface }}.network
    - source: salt://global/common/networkd/files/proxmox-networkd-conf
    - template: jinja
    - context:
        main_iface: {{ data.proxmox_nodes[host].main_iface }}
{{ host }}_10_vmbr0_netdev_conf:
  file.managed:
    - name: /etc/systemd/network/10-vmbr0.netdev
    - source: salt://global/common/networkd/files/10-vmbr0.netdev
{{ host }}_20_vmbr0_network_conf:
  file.managed:
    - name: /etc/systemd/network/20-vmbr0.network
    - source: salt://global/common/networkd/files/20-vmbr0.network
    - template: jinja
    - context:
        gateway: {{ data.network.gateway }}
        ip_addr: {{ data.proxmox_nodes[host].ip_addr }}
        dns_nameservers: {{ data.network.dns_nameservers }}
        domain: {{ domain }}
{% elif is_vm %}
{{ host }}_network_conf:
  file.managed:
    - name: /etc/systemd/network/10-{{ (data.proxmox_vms | selectattr('vm_name', 'equalto', host) | first).main_iface }}.network
    - source: salt://global/common/networkd/files/default-networkd-conf
    - template: jinja
    - context:
        gateway: {{ data.network.gateway }}
        main_iface: {{ (data.proxmox_vms | selectattr('vm_name', 'equalto', host) | first).main_iface }}
        ip_addr: {{ (data.proxmox_vms | selectattr('vm_name', 'equalto', host) | first).ip_addr }}
        dns_nameservers: {{ data.network.dns_nameservers }}
        domain: {{ domain }}
{% else %}
network_conf_absent_warning:
  test.show_notification:
    - text: "COMPLETE THE NETWORK CONFIGURATION FOR {{ host }} IN DATA/MAIN.JSON"
{% endif %}

service_systemd_networkd:
  service.running:
    - name: systemd-networkd
    - enable: True

service_systemd_resolved:
  service.running:
    - name: systemd-resolved
    - enable: True

resolv_conf_symlink:
  file.symlink:
    - name: /etc/resolv.conf
    - target: /run/systemd/resolve/stub-resolv.conf
    - force: True
    - makedirs: True
    - require:
      - service: service_systemd_resolved