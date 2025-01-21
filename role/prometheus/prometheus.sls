{% set prometheus_version = '2.53.0' %}
{% import_json 'data/main.json' as data %}
{% set proxmox_nodes = data.proxmox_nodes.keys() | list %}
{% set proxmox_vms = data.proxmox_vms | map(attribute='vm_name') | list %}
{% set host_list = proxmox_nodes + proxmox_vms %}
{% set domain = data.network.domain %}

prometheus_user:
  user.present:
    - name: prometheus
    - usergroup: True
    - createhome: False
    - system: True

extract_prometheus:
  archive.extracted:
    - name: /etc/
    - source: https://github.com/prometheus/prometheus/releases/download/v{{ prometheus_version }}/prometheus-{{ prometheus_version }}.linux-amd64.tar.gz
    - user: prometheus
    - group: prometheus
    - mode: 755
    - if_missing: /etc/prometheus
    - skip_verify: True

rename_prometheus_directory:
  file.rename:
    - name: /etc/prometheus
    - source: /etc/prometheus-{{ prometheus_version }}.linux-amd64
    - require:
      - archive: extract_prometheus

prometheus_config:
  file.managed:
    - name: /etc/prometheus/prometheus.yml
    - source: salt://role/prometheus/files/prometheus.yml
    - mode: 644
    - user: prometheus
    - group: prometheus
    - template: jinja
    - context:
        hosts: {{ host_list }}
        domain: {{ domain }}
    - require:
      - archive: extract_prometheus

prometheus_rules:
  file.recurse:
    - name: /etc/prometheus/rules
    - source: salt://role/prometheus/files/rules
    - include_empty: True

prometheus_service:
  file.managed:
    - name: /etc/systemd/system/prometheus.service
    - source: salt://role/prometheus/files/prometheus.service
    - mode: 755
    - user: root
    - group: root
    - require:
      - archive: extract_prometheus

start_enable_prometheus_service:
  service.running:
    - name: prometheus
    - enable: True
    - watch:
      - file: prometheus_config
      - file: prometheus_rules
