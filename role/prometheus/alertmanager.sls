{% set alertmanager_version = '0.27.0' %}
{% set webhook_url = salt['vault'].read_secret('kv/prometheus').webhook_url %}

alertmanager:
  user.present:
    - usergroup: True
    - createhome: False
    - system: True

/etc/alertmanager-{{ alertmanager_version }}.linux-amd64:
  archive.extracted:
    - source: https://github.com/prometheus/alertmanager/releases/download/v{{ alertmanager_version }}/alertmanager-{{ alertmanager_version }}.linux-amd64.tar.gz
    - user: alertmanager
    - group: alertmanager
    - mode: 755
    - if_missing: /etc/alertmanager
    - skip_verify: True

/etc/alertmanager:
  file.rename:
    - source: /etc/alertmanager-{{ alertmanager_version }}.linux-amd64
    - require:
      - archive: /etc/alertmanager-{{ alertmanager_version }}.linux-amd64

/etc/alertmanager/alertmanager.yml:
  file.managed:
    - source: salt://role/prometheus/files/alertmanager.yml
    - mode: 644
    - user: alertmanager
    - group: alertmanager
    - require:
      - file: /etc/alertmanager
    - template: jinja
    - context:
        webhook_url: {{ webhook_url }}

/etc/systemd/system/alertmanager.service:
  file.managed:
    - source: salt://role/prometheus/files/alertmanager.service
    - mode: 755
    - user: root
    - group: root
    - require:
      - file: /etc/alertmanager

alertmanager_service:
  service.running:
    - name: alertmanager
    - enable: True
    - watch:
      - file: /etc/alertmanager/alertmanager.yml
