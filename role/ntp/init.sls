/etc/chrony/chrony.conf:
  file.managed:
    - source: salt://role/ntp/files/chrony.conf
    - mode: 644
    - user: root
    - group: root

service_chrony:
  service.running:
    - name: chrony
    - enable: True
    - watch:
      - file: /etc/chrony/chrony.conf
