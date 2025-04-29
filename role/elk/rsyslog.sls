/etc/rsyslog.conf:
  file.managed:
    - source: salt://role/elk/files/rsyslog.conf
    - mode: 644
    - user: root
    - group: root

service_rsyslog:
  service.running:
    - name: rsyslog
    - enable: True
    - watch:
      - file: /etc/rsyslog.conf
