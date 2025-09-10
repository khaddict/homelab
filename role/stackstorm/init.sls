{% import_json 'data/main.json' as data %}

{% set ca_password = salt['vault'].read_secret('kv/ca/ca').ca_password %}
{% set netbox_api_token = salt['vault'].read_secret('kv/stackstorm/netbox').api_token %}
{% set messaging_url = salt['vault'].read_secret('kv/stackstorm/st2').messaging_url %}
{% set database_password = salt['vault'].read_secret('kv/stackstorm/st2').database_password %}
{% set database_password = salt['vault'].read_secret('kv/stackstorm/st2').database_password %}
{% set powerdns_api_key = salt['vault'].read_secret('kv/stackstorm/powerdns').api_key %}
{% set snapshot_vms_discord_webhook = salt['vault'].read_secret('kv/stackstorm/st2_homelab').snapshot_vms_discord_webhook %}

/etc/default/st2actionrunner:
  file.managed:
    - source: salt://role/stackstorm/files/st2actionrunner
    - mode: 644
    - user: root
    - group: root

/etc/st2/st2.conf:
  file.managed:
    - source: salt://role/stackstorm/files/st2.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        messaging_url: {{ messaging_url }}
        database_password: {{ database_password }}

/etc/nginx/conf.d/st2.conf:
  file.managed:
    - source: salt://role/stackstorm/files/st2_nginx.conf
    - mode: 644
    - user: root
    - group: root

https://github.com/khaddict/orquestaevaluator.git:
  git.latest:
    - target: /opt/orquestaevaluator
    - user: root

/etc/systemd/system/orquesta_evaluator.service:
  file.managed:
    - source: salt://role/stackstorm/files/orquesta_evaluator.service
    - mode: 644
    - user: root
    - group: root
    - require:
      - git: https://github.com/khaddict/orquestaevaluator.git

orquesta_evaluator_service:
  service.running:
    - name: orquesta_evaluator
    - enable: True
    - require:
      - file: /etc/systemd/system/orquesta_evaluator.service
    - watch:
      - file: /etc/systemd/system/orquesta_evaluator.service

# Packs

/opt/stackstorm/packs/st2_homelab:
  file.recurse:
    - source: salt://role/stackstorm/files/packs/st2_homelab
    - include_empty: True
    - template: jinja
    - context:
        dns: {{ data.network.dns_nameservers.powerdns_recursor }}
        netmask: {{ data.network.netmask }}
        gateway: {{ data.network.gateway }}
        domain: {{ data.network.domain }}
        snapshot_vms_discord_webhook: {{ snapshot_vms_discord_webhook }}

/opt/stackstorm/packs/netbox:
  file.recurse:
    - source: salt://role/stackstorm/files/packs/netbox
    - include_empty: True

/opt/stackstorm/packs/powerdns:
  file.recurse:
    - source: salt://role/stackstorm/files/packs/powerdns
    - include_empty: True

# Configs

/opt/stackstorm/configs/st2_homelab.yaml:
  file.managed:
    - source: salt://role/stackstorm/files/configs/st2_homelab.yaml
    - mode: 660
    - user: root
    - group: st2packs
    - template: jinja
    - context:
        ca_password: {{ ca_password }}

/opt/stackstorm/configs/netbox.yaml:
  file.managed:
    - source: salt://role/stackstorm/files/configs/netbox.yaml
    - mode: 660
    - user: root
    - group: st2packs
    - template: jinja
    - context:
        netbox_api_token: {{ netbox_api_token }}

/opt/stackstorm/configs/powerdns.yaml:
  file.managed:
    - source: salt://role/stackstorm/files/configs/powerdns.yaml
    - mode: 660
    - user: root
    - group: st2packs
    - template: jinja
    - context:
        powerdns_api_key: {{ powerdns_api_key }}

# Data

/opt/stackstorm/data/main.json:
  file.managed:
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
      - file: /opt/stackstorm/packs/st2_homelab
    - onchanges:
      - file: /opt/stackstorm/packs/st2_homelab
      - file: /opt/stackstorm/configs/st2_homelab.yaml

netbox_installation:
  cmd.run:
    - name: "st2 pack install file:///opt/stackstorm/packs/netbox/"
    - require: 
      - file: /opt/stackstorm/packs/netbox
    - onchanges:
      - file: /opt/stackstorm/packs/netbox
      - file: /opt/stackstorm/configs/netbox.yaml

powerdns_installation:
  cmd.run:
    - name: "st2 pack install file:///opt/stackstorm/packs/powerdns/"
    - require: 
      - file: /opt/stackstorm/packs/powerdns
    - onchanges:
      - file: /opt/stackstorm/packs/powerdns
      - file: /opt/stackstorm/configs/powerdns.yaml
