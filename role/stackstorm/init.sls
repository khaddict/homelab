{% import_yaml 'data/network_confs.yaml' as network_confs %}

{% set ca_password = salt['vault'].read_secret('kv/ca/ca').ca_password %}
{% set netbox_api_token = salt['vault'].read_secret('kv/stackstorm/netbox').api_token %}
{% set messaging_url = salt['vault'].read_secret('kv/stackstorm/st2').messaging_url %}
{% set database_password = salt['vault'].read_secret('kv/stackstorm/st2').database_password %}
{% set database_password = salt['vault'].read_secret('kv/stackstorm/st2').database_password %}
{% set powerdns_api_key = salt['vault'].read_secret('kv/stackstorm/powerdns').api_key %}
{% set snapshot_vms_discord_webhook = salt['vault'].read_secret('kv/stackstorm/st2_homelab').snapshot_vms_discord_webhook %}

st2actionrunner_file:
  file.managed:
    - name: /etc/default/st2actionrunner
    - source: salt://role/stackstorm/files/st2actionrunner
    - mode: 644
    - user: root
    - group: root

st2_config:
  file.managed:
    - name: /etc/st2/st2.conf
    - source: salt://role/stackstorm/files/st2.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        messaging_url: {{ messaging_url }}
        database_password: {{ database_password }}

st2_nginx_config:
  file.managed:
    - name: /etc/nginx/conf.d/st2.conf
    - source: salt://role/stackstorm/files/st2_nginx.conf
    - mode: 644
    - user: root
    - group: root

clone_orquesta_evaluator:
  git.latest:
    - name: https://github.com/khaddict/orquestaevaluator.git
    - target: /opt/orquestaevaluator
    - user: root

orquesta_evaluator_service:
  file.managed:
    - name: /etc/systemd/system/orquesta_evaluator.service
    - source: salt://role/stackstorm/files/orquesta_evaluator.service
    - mode: 644
    - user: root
    - group: root
    - require:
      - git: clone_orquesta_evaluator

start_enable_orquesta_evaluator_service:
  service.running:
    - name: orquesta_evaluator
    - enable: True
    - require:
      - file: orquesta_evaluator_service
    - watch:
      - file: orquesta_evaluator_service

# Packs

st2_homelab_folder:
  file.recurse:
    - name: /opt/stackstorm/packs/st2_homelab
    - source: salt://role/stackstorm/files/packs/st2_homelab
    - include_empty: True
    - template: jinja
    - context:
        dns: {{ network_confs.dns_nameservers.powerdns_recursor }}
        netmask: {{ network_confs.netmask }}
        gateway: {{ network_confs.gateway }}
        snapshot_vms_discord_webhook: {{ snapshot_vms_discord_webhook }}

netbox_folder:
  file.recurse:
    - name: /opt/stackstorm/packs/netbox
    - source: salt://role/stackstorm/files/packs/netbox
    - include_empty: True

powerdns_folder:
  file.recurse:
    - name: /opt/stackstorm/packs/powerdns
    - source: salt://role/stackstorm/files/packs/powerdns
    - include_empty: True

# Configs

st2_homelab_configs:
  file.managed:
    - name: /opt/stackstorm/configs/st2_homelab.yaml
    - source: salt://role/stackstorm/files/configs/st2_homelab.yaml
    - mode: 660
    - user: root
    - group: st2packs
    - template: jinja
    - context:
        ca_password: {{ ca_password }}

netbox_configs:
  file.managed:
    - name: /opt/stackstorm/configs/netbox.yaml
    - source: salt://role/stackstorm/files/configs/netbox.yaml
    - mode: 660
    - user: root
    - group: st2packs
    - template: jinja
    - context:
        netbox_api_token: {{ netbox_api_token }}

powerdns_configs:
  file.managed:
    - name: /opt/stackstorm/configs/powerdns.yaml
    - source: salt://role/stackstorm/files/configs/powerdns.yaml
    - mode: 660
    - user: root
    - group: st2packs
    - template: jinja
    - context:
        powerdns_api_key: {{ powerdns_api_key }}

# Data

main_data:
  file.managed:
    - name: /opt/stackstorm/data/main.json
    - source: salt://data/main.json
    - mode: 644
    - user: root
    - group: root
    - makedirs: True

# Installations

st2_homelab_installation:
  cmd.run:
    - name: "st2 pack install file:///opt/stackstorm/packs/st2_homelab/"
    - require: 
      - file: st2_homelab_folder
    - onchanges:
      - file: st2_homelab_folder
      - file: st2_homelab_configs

netbox_installation:
  cmd.run:
    - name: "st2 pack install file:///opt/stackstorm/packs/netbox/"
    - require: 
      - file: netbox_folder
    - onchanges:
      - file: netbox_folder
      - file: netbox_configs

powerdns_installation:
  cmd.run:
    - name: "st2 pack install file:///opt/stackstorm/packs/powerdns/"
    - require: 
      - file: powerdns_folder
    - onchanges:
      - file: powerdns_folder
      - file: powerdns_configs
