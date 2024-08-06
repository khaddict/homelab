{% set database_password = salt['vault'].read_secret('kv/netbox').database_password %}
{% set secret_key = salt['vault'].read_secret('kv/netbox').secret_key %}

include:
  - base.postgresql
  - base.redis
  - base.nginx

netbox_db_script:
  file.managed:
    - name: /tmp/netbox_db.sh
    - source: salt://role/netbox/files/netbox_db.sh
    - mode: 755
    - user: root
    - group: root

netbox_dependencies:
  pkg.installed:
    - pkgs:
      - python3
      - python3-pip
      - python3-venv
      - python3-dev
      - build-essential
      - libxml2-dev
      - libxslt1-dev
      - libffi-dev
      - libpq-dev
      - libssl-dev
      - zlib1g-dev
      - git

opt_netbox_dir:
  file.directory:
    - name: /opt/netbox
    - mode: 755

netbox_repo:
  git.latest:
    - name: https://github.com/netbox-community/netbox.git
    - target: /opt/netbox
    - branch: master
    - rev: master
    - depth: 1
    - require:
      - file: opt_netbox_dir

netbox_user:
  user.present:
    - name: netbox
    - usergroup: True

netbox_media_chown:
  file.directory:
    - name: /opt/netbox/netbox/media
    - user: netbox
    - group: netbox

netbox_reports_chown:
  file.directory:
    - name: /opt/netbox/netbox/reports
    - user: netbox
    - group: netbox

netbox_scripts_chown:
  file.directory:
    - name: /opt/netbox/netbox/scripts
    - user: netbox
    - group: netbox

configuration_file:
  file.managed:
    - name: /opt/netbox/netbox/netbox/configuration.py
    - source: salt://role/netbox/files/configuration.py
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        database_password: {{ database_password }}
        secret_key: {{ secret_key }}

gunicorn_config:
  file.managed:
    - name: /opt/netbox/gunicorn.py
    - source: salt://role/netbox/files/gunicorn.py
    - mode: 644
    - user: root
    - group: root

netbox_housekeeping_service:
  file.managed:
    - name: /etc/systemd/system/netbox-housekeeping.service
    - source: salt://role/netbox/files/netbox-housekeeping.service
    - mode: 644
    - user: root
    - group: root

netbox_service:
  file.managed:
    - name: /etc/systemd/system/netbox.service
    - source: salt://role/netbox/files/netbox.service
    - mode: 644
    - user: root
    - group: root

netbox_rq_service:
  file.managed:
    - name: /etc/systemd/system/netbox-rq.service
    - source: salt://role/netbox/files/netbox-rq.service
    - mode: 644
    - user: root
    - group: root

start_enable_netbox_service:
  service.running:
    - name: netbox
    - enable: True
    - watch:
      - file: netbox_service

start_enable_netbox_rq_service:
  service.running:
    - name: netbox-rq
    - enable: True
    - watch:
      - file: netbox_rq_service

netbox_config:
  file.managed:
    - name: /etc/nginx/sites-available/netbox
    - source: salt://role/netbox/files/netbox
    - mode: 644
    - user: root
    - group: root

remove_nginx_default:
  file.absent:
    - name: /etc/nginx/sites-enabled/default

create_netbox_symlink:
  file.symlink:
    - name: /etc/nginx/sites-enabled/netbox
    - target: /etc/nginx/sites-available/netbox

restart_nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - watch:
      - file: netbox_config
