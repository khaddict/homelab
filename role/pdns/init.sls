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

/tmp/pdns_db.sh:
  file.managed:
    - source: salt://role/pdns/files/pdns_db.sh
    - mode: 755
    - user: root
    - group: root

/etc/apt/sources.list.d/pdns.list:
  pkgrepo.managed:
    - name: deb [signed-by=/etc/apt/keyrings/auth-49-pub.asc] http://repo.powerdns.com/debian {{ oscodename }}-auth-49 main
    - file: /etc/apt/sources.list.d/pdns.list

/etc/apt/preferences.d/auth-49:
  file.managed:
    - source: salt://role/pdns/files/auth-49
    - mode: 644
    - user: root
    - group: root

/etc/apt/keyrings/auth-49-pub.asc:
  file.managed:
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
      - file: /etc/apt/keyrings/auth-49-pub.asc
      - pkgrepo: /etc/apt/sources.list.d/pdns.list
      - file: /etc/apt/preferences.d/auth-49

/etc/powerdns/pdns.d/pdns.local.gmysql.conf:
  file.managed:
    - source: salt://role/pdns/files/pdns.local.gmysql.conf
    - mode: 640
    - user: pdns
    - group: pdns
    - template: jinja
    - context:
        powerdns_db_password: {{ powerdns_db_password }}
    - require:
      - pkg: install_pdns

/etc/powerdns/pdns.conf:
  file.managed:
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
      - file: /etc/powerdns/pdns.d/pdns.local.gmysql.conf
    - watch:
      - file: /etc/powerdns/pdns.d/pdns.local.gmysql.conf
      - file: /etc/powerdns/pdns.conf

/tmp/setup_20.x:
  file.managed:
    - source: https://deb.nodesource.com/setup_20.x
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
    - skip_verify: True

execute_nodejs_script:
  cmd.run:
    - name: /usr/bin/bash /tmp/setup_20.x
    - require:
      - file: /tmp/setup_20.x
    - onchanges:
      - /tmp/setup_20.x

nodejs:
  pkg.installed:
    - require:
      - file: /tmp/setup_20.x
      - cmd: execute_nodejs_script

/usr/share/keyrings/yarnkey.gpg:
  file.managed:
    - source: salt://role/pdns/files/yarnkey.gpg
    - mode: 644
    - user: root
    - group: root

/etc/apt/sources.list.d/yarn.list:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main
    - file: /etc/apt/sources.list.d/yarn.list

yarn:
  pkg.installed:
    - require:
      - file: /usr/share/keyrings/yarnkey.gpg
      - pkgrepo: /etc/apt/sources.list.d/yarn.list

https://github.com/ngoduykhanh/PowerDNS-Admin.git:
  git.latest:
    - target: /var/www/html/pdns
    - user: root

/var/www/html/pdns/flask:
  virtualenv.managed:
    - requirements: /var/www/html/pdns/requirements.txt
    - require:
      - git: https://github.com/ngoduykhanh/PowerDNS-Admin.git

/var/www/html/pdns/powerdnsadmin/default_config.py:
  file.managed:
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
      - virtualenv: /var/www/html/pdns/flask

/etc/nginx/sites-enabled/default:
  file.absent

/etc/nginx/conf.d/powerdns-admin.conf:
  file.managed:
    - source: salt://role/pdns/files/powerdns-admin.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: /etc/nginx/sites-enabled/default

service_nginx:
  service.running:
    - name: nginx
    - enable: True
    - require:
      - file: /etc/nginx/conf.d/powerdns-admin.conf
    - watch:
      - file: /etc/nginx/conf.d/powerdns-admin.conf

/etc/systemd/system/pdnsadmin.service:
  file.managed:
    - source: salt://role/pdns/files/pdnsadmin.service
    - mode: 644
    - user: root
    - group: root

/etc/systemd/system/pdnsadmin.socket:
  file.managed:
    - source: salt://role/pdns/files/pdnsadmin.socket
    - mode: 644
    - user: root
    - group: root

/etc/tmpfiles.d/pdnsadmin.conf:
  file.managed:
    - source: salt://role/pdns/files/pdnsadmin.conf
    - mode: 644
    - user: root
    - group: root

pdnsadmin_service:
  service.running:
    - name: pdnsadmin.service
    - enable: True
    - watch:
      - file: /etc/systemd/system/pdnsadmin.service
      - file: /etc/systemd/system/pdnsadmin.socket
      - file: /etc/tmpfiles.d/pdnsadmin.conf

pdnsadmin_socket:
  service.running:
    - name: pdnsadmin.socket
    - enable: True
    - watch:
      - file: /etc/systemd/system/pdnsadmin.service
      - file: /etc/systemd/system/pdnsadmin.socket
      - file: /etc/tmpfiles.d/pdnsadmin.conf
      - service: pdnsadmin_service
