install_aptly:
  pkg.installed:
    - name: aptly

aptly_service:
  file.managed:
    - name: /etc/systemd/system/aptly.service
    - source: salt://role/aptly/files/aptly.service
    - mode: 644
    - user: root
    - group: root

start_enable_aptly_service:
  service.running:
    - name: aptly
    - enable: True
    - watch:
      - file: aptly_service
