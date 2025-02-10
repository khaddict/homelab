{% import_json 'data/main.json' as data %}
{% set domain = data.network.domain %}
{% set host = grains["host"] %}

{% set is_proxmox_node = host in data.proxmox_nodes %}
{% set is_vm = host in data.proxmox_vms | map(attribute='vm_name') %}

{% if host is not match('k(control|worker)0[1-3]') %}
{{ host }}_hosts_conf:
  file.managed:
    - name: /etc/hosts
    - source: salt://global/common/hosts/files/hosts
    - template: jinja
    - context:
        host: {{ host }}
        fqdn: {{ host }}.{{ domain }}
        ip_addr: {{ (data.proxmox_nodes[host].ip_addr if is_proxmox_node else (data.proxmox_vms | selectattr('vm_name', 'equalto', host) | first).ip_addr) }}
{% endif %}

{% if not is_proxmox_node and not is_vm %}
network_conf_absent_warning:
  test.show_notification:
    - text: "COMPLETE THE NETWORK CONFIGURATION FOR {{ host }} IN DATA/MAIN.JSON"
{% endif %}
