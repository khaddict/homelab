{% set osarch = grains["osarch"] %}
{% set oscodename = grains["oscodename"] %}
{% set powerdns_db_password = salt['vault'].read_secret('kv/powerdns').powerdns_db_password %}
{% set powerdns_api_key = salt['vault'].read_secret('kv/powerdns').powerdns_api_key %}
{% set powerdns_salt = salt['vault'].read_secret('kv/powerdns').powerdns_salt %}
{% set powerdns_secret_key = salt['vault'].read_secret('kv/powerdns').powerdns_secret_key %}

include:
  - base.mariadb
  - base.nginx
  - base.virtualenv
  - base.python311_venv

pdns_dependencies:
  pkg.installed:
    - pkgs:
      - libpq-dev
      - python3-dev
      - libsasl2-dev
      - libldap2-dev
      - libssl-dev
      - libxml2-dev
      - libxslt1-dev
      - libxmlsec1-dev
      - libffi-dev
      - pkg-config
      - apt-transport-https
      - build-essential
      - libmariadb-dev
      - python3-flask

pdns_db_script:
  file.managed:
    - name: /tmp/pdns_db.sh
    - source: salt://role/pdns/files/pdns_db.sh
    - mode: 755
    - user: root
    - group: root

pdns_repo_pkg:
  pkgrepo.managed:
    - name: deb [signed-by=/etc/apt/keyrings/auth-49-pub.asc] http://repo.powerdns.com/debian {{ oscodename }}-auth-49 main
    - file: /etc/apt/sources.list.d/pdns.list

pdns_preferences:
  file.managed:
    - name: /etc/apt/preferences.d/auth-49
    - source: salt://role/pdns/files/auth-49
    - mode: 644
    - user: root
    - group: root

pdns_keyrings:
  file.managed:
    - name: /etc/apt/keyrings/auth-49-pub.asc
    - source: salt://role/pdns/files/auth-49-pub.asc
    - mode: 644
    - user: root
    - group: root

install_pdns:
  pkg.installed:
    - pkgs:
      - pdns-server
      - pdns-backend-mysql
    - require:
      - file: pdns_keyrings
      - pkgrepo: pdns_repo_pkg
      - file: pdns_preferences

gmysql_config:
  file.managed:
    - name: /etc/powerdns/pdns.d/pdns.local.gmysql.conf
    - source: salt://role/pdns/files/pdns.local.gmysql.conf
    - mode: 640
    - user: pdns
    - group: pdns
    - template: jinja
    - context:
        powerdns_db_password: {{ powerdns_db_password }}
    - require:
      - pkg: install_pdns

pdns_config:
  file.managed:
    - name: /etc/powerdns/pdns.conf
    - source: salt://role/pdns/files/pdns.conf
    - mode: 640
    - user: root
    - group: pdns
    - template: jinja
    - context:
        powerdns_api_key: {{ powerdns_api_key }}
    - require:
      - pkg: install_pdns

service_pdns:
  service.running:
    - name: pdns
    - enable: True
    - require:
      - file: gmysql_config
    - watch:
      - file: gmysql_config
      - file: pdns_config

download_nodejs_script:
  file.managed:
    - name: /tmp/setup_20.x
    - source: https://deb.nodesource.com/setup_20.x
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
    - skip_verify: True

execute_nodejs_script:
  cmd.run :
    - name: /usr/bin/bash /tmp/setup_20.x
    - require:
      - file: download_nodejs_script
    - onchanges:
      - download_nodejs_script

install_nodejs:
  pkg.installed:
    - name: nodejs
    - require:
      - file: download_nodejs_script
      - cmd: execute_nodejs_script

yarnkey_keyrings:
  file.managed:
    - name: /usr/share/keyrings/yarnkey.gpg
    - source: salt://role/pdns/files/yarnkey.gpg
    - mode: 644
    - user: root
    - group: root

yarnkey_repo_pkg:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main
    - file: /etc/apt/sources.list.d/yarn.list

install_yarn:
  pkg.installed:
    - name: yarn
    - require:
      - file: yarnkey_keyrings
      - pkgrepo: yarnkey_repo_pkg

clone_powerdns_admin:
  git.latest:
    - name: https://github.com/ngoduykhanh/PowerDNS-Admin.git
    - target: /var/www/html/pdns
    - user: root

setup_venv_flask:
  virtualenv.managed:
    - name: /var/www/html/pdns/flask
    - requirements: /var/www/html/pdns/requirements.txt
    - require:
      - git: clone_powerdns_admin

pdns_default_config:
  file.managed:
    - name: /var/www/html/pdns/powerdnsadmin/default_config.py
    - source: salt://role/pdns/files/default_config.py
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        powerdns_db_password: {{ powerdns_db_password }}
        powerdns_secret_key: {{ powerdns_secret_key }}
        powerdns_salt: {{ powerdns_salt }}
    - require:
      - virtualenv: setup_venv_flask

remove_nginx_default:
  file.absent:
    - name: /etc/nginx/sites-enabled/default

pdns_nginx_config:
  file.managed:
    - name: /etc/nginx/conf.d/powerdns-admin.conf
    - source: salt://role/pdns/files/powerdns-admin.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: remove_nginx_default

service_nginx:
  service.running:
    - name: nginx
    - enable: True
    - require:
      - file: pdns_nginx_config
    - watch:
      - file: pdns_nginx_config

pdnsadmin_service:
  file.managed:
    - name: /etc/systemd/system/pdnsadmin.service
    - source: salt://role/pdns/files/pdnsadmin.service
    - mode: 644
    - user: root
    - group: root

pdnsadmin_socket:
  file.managed:
    - name: /etc/systemd/system/pdnsadmin.socket
    - source: salt://role/pdns/files/pdnsadmin.socket
    - mode: 644
    - user: root
    - group: root

pdnsadmin_config:
  file.managed:
    - name: /etc/tmpfiles.d/pdnsadmin.conf
    - source: salt://role/pdns/files/pdnsadmin.conf
    - mode: 644
    - user: root
    - group: root

start_enable_pdnsadmin_service:
  service.running:
    - name: pdnsadmin.service
    - enable: True
    - watch:
      - file: pdnsadmin_service
      - file: pdnsadmin_socket
      - file: pdnsadmin_config

start_enable_pdnsadmin_socket:
  service.running:
    - name: pdnsadmin.socket
    - enable: True
    - watch:
      - file: pdnsadmin_service
      - file: pdnsadmin_socket
      - file: pdnsadmin_config
      - service: start_enable_pdnsadmin_service
