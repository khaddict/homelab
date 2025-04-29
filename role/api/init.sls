include:
  - base.python311_venv

/opt/api_homelab:
  file.recurse:
    - source: salt://role/api/files/api_homelab
    - include_empty: True

/etc/systemd/system/api_homelab.service:
  file.managed:
    - source: salt://role/api/files/api_homelab.service
    - mode: 644
    - user: root
    - group: root

start_enable_api_homelab_service:
  service.running:
    - name: api_homelab
    - enable: True
    - watch:
      - file: /etc/systemd/system/api_homelab.service
