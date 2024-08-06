include:
  - base.rsyslog

{% if grains["fqdn"] != "elk.homelab.lan" %}
rsyslog_client_config:
  file.managed:
    - name: /etc/rsyslog.conf
    - source: salt://global/common/rsyslog/files/rsyslog.conf
    - mode: 644
    - user: root
    - group: root
{% endif %}

enable_service_rsyslog_client:
  service.running:
    - name: rsyslog
    - enable: True
{% if grains["fqdn"] != "elk.homelab.lan" %}
    - watch:
      - file: rsyslog_client_config
{% endif %}
