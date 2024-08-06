{% set netbox_addr = salt['vault'].read_secret('kv/work').netbox_addr %}
{% set netbox_token_ro = salt['vault'].read_secret('kv/work').netbox_token_ro %}
{% set netbox_token_rw = salt['vault'].read_secret('kv/work').netbox_token_rw %}
{% set ovh_application_key_eu = salt['vault'].read_secret('kv/work').ovh_application_key_eu %}
{% set ovh_application_key_us = salt['vault'].read_secret('kv/work').ovh_application_key_us %}
{% set ovh_application_secret_eu = salt['vault'].read_secret('kv/work').ovh_application_secret_eu %}
{% set ovh_application_secret_us = salt['vault'].read_secret('kv/work').ovh_application_secret_us %}
{% set ovh_consumer_key_eu = salt['vault'].read_secret('kv/work').ovh_consumer_key_eu %}
{% set ovh_consumer_key_us = salt['vault'].read_secret('kv/work').ovh_consumer_key_us %}
{% set ovh_endpoint_eu = salt['vault'].read_secret('kv/work').ovh_endpoint_eu %}
{% set ovh_endpoint_us = salt['vault'].read_secret('kv/work').ovh_endpoint_us %}
{% set pdns_api_key = salt['vault'].read_secret('kv/work').pdns_api_key %}
{% set pdns_server = salt['vault'].read_secret('kv/work').pdns_server %}
{% set vault_addr = salt['vault'].read_secret('kv/work').vault_addr %}
{% set vault_token = salt['vault'].read_secret('kv/work').vault_token %}


include:
  - base.openvpn
  - base.python311_venv
  - base.direnv
  - base.dnsmasq

openvpn_service:
  file.managed:
    - name: /etc/systemd/system/work_homelab_vpn.service
    - source: salt://role/work/files/work_homelab_vpn.service
    - mode: 644
    - user: root
    - group: root

start_enable_openvpn_service:
  service.running:
    - name: work_homelab_vpn
    - enable: True
    - watch:
      - file: openvpn_service

rma_folder:
  file.recurse:
    - name: /root/tools/rma
    - source: salt://role/work/files/tools/rma
    - include_empty: True
    - makedirs: True
    - template: jinja
    - context:
        netbox_token_ro: {{ netbox_token_ro }}

dns_folder:
  file.recurse:
    - name: /root/tools/dns
    - source: salt://role/work/files/tools/dns
    - include_empty: True
    - makedirs: True
    - file_mode: 755

work_bashrc:
  file.managed:
    - name: /root/.bashrc.d/work.bashrc
    - source: salt://role/work/files/work.bashrc
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        netbox_addr: {{ netbox_addr }}
        netbox_token_rw: {{ netbox_token_rw }}
        ovh_application_key_eu: {{ ovh_application_key_eu }}
        ovh_application_key_us: {{ ovh_application_key_us }}
        ovh_application_secret_eu: {{ ovh_application_secret_eu }}
        ovh_application_secret_us: {{ ovh_application_secret_us }}
        ovh_consumer_key_eu: {{ ovh_consumer_key_eu }}
        ovh_consumer_key_us: {{ ovh_consumer_key_us }}
        ovh_endpoint_eu: {{ ovh_endpoint_eu }}
        ovh_endpoint_us: {{ ovh_endpoint_us }}
        pdns_api_key: {{ pdns_api_key }}
        pdns_server: {{ pdns_server }}
        vault_addr: {{ vault_addr }}
        vault_token: {{ vault_token }}
