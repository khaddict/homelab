include:
  - base.python311_venv

api_homelab_directory:
  file.recurse:
    - name: /opt/api_homelab
    - source: salt://role/api/files/api_homelab
    - include_empty: True

api_homelab_service:
  file.managed:
    - name: /etc/systemd/system/api_homelab.service
    - source: salt://role/api/files/api_homelab.service
    - mode: 644
    - user: root
    - group: root

start_enable_api_homelab_service:
  service.running:
    - name: api_homelab
    - enable: True
    - watch:
      - file: api_homelab_directory
      - file: api_homelab_service
