{% set prometheus_version = '2.53.0' %}
{% import_json 'data/main.json' as data %}
{% set proxmox_nodes = data.proxmox_nodes.keys() | list %}
{% set proxmox_vms = data.proxmox_vms | map(attribute='vm_name') | list %}
{% set host_list = proxmox_nodes + proxmox_vms %}
{% set domain = data.network.domain %}

prometheus:
  user.present:
    - usergroup: True
    - createhome: False
    - system: True

/etc/prometheus-{{ prometheus_version }}.linux-amd64:
  archive.extracted:
    - source: https://github.com/prometheus/prometheus/releases/download/v{{ prometheus_version }}/prometheus-{{ prometheus_version }}.linux-amd64.tar.gz
    - user: prometheus
    - group: prometheus
    - mode: 755
    - if_missing: /etc/prometheus
    - skip_verify: True

/etc/prometheus:
  file.rename:
    - source: /etc/prometheus-{{ prometheus_version }}.linux-amd64
    - require:
      - archive: /etc/prometheus-{{ prometheus_version }}.linux-amd64

/etc/prometheus/prometheus.yml:
  file.managed:
    - source: salt://role/prometheus/files/prometheus.yml
    - mode: 644
    - user: prometheus
    - group: prometheus
    - template: jinja
    - context:
        hosts: {{ host_list }}
        domain: {{ domain }}
    - require:
      - file: /etc/prometheus

/etc/prometheus/rules:
  file.recurse:
    - source: salt://role/prometheus/files/rules
    - include_empty: True

/etc/systemd/system/prometheus.service:
  file.managed:
    - source: salt://role/prometheus/files/prometheus.service
    - mode: 755
    - user: root
    - group: root

prometheus_service:
  service.running:
    - name: prometheus
    - enable: True
    - watch:
      - file: /etc/prometheus/prometheus.yml
      - file: /etc/prometheus/rules
