{% set admin_api_key = salt['vault'].read_secret('kv/powerdns').admin_api_key %}
{% set login_webhook_url = salt['vault'].read_secret('kv/main').login_webhook_url %}

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

login_script:
  file.managed:
    - name: /root/login/login.sh
    - source: salt://role/main/files/login.sh
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - context:
        login_webhook_url: {{ login_webhook_url }}

login_service:
  file.managed:
    - name: /etc/systemd/system/login.service
    - source: salt://role/main/files/login.service
    - mode: 644
    - user: root
    - group: root

start_enable_login_service:
  service.running:
    - name: login
    - enable: True
    - watch:
      - file: login_service
