rsyslog_server_config:
  file.managed:
    - name: /etc/rsyslog.conf
    - source: salt://role/elk/files/rsyslog.conf
    - mode: 644
    - user: root
    - group: root

enable_service_rsyslog_server:
  service.running:
    - name: rsyslog
    - enable: True
    - watch:
      - file: rsyslog_server_config
