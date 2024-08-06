{% set admin_api_key = salt['vault'].read_secret('kv/powerdns').admin_api_key %}

vars_bashrc:
  file.managed:
    - name: /root/.bashrc.d/vars.bashrc
    - source: salt://role/main/files/vars.bashrc
    - mode: 700
    - user: root
    - group: root
    - template: jinja
    - context:
        admin_api_key: {{ admin_api_key }}
