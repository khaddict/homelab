{% set database_password = salt['vault'].read_secret('kv/netbox').database_password %}
{% set secret_key = salt['vault'].read_secret('kv/netbox').secret_key %}

include:
  - base.postgresql
  - base.redis
  - base.nginx

/opt/netbox_db.sh:
  file.managed:
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

/opt/netbox:
  file.directory:
    - mode: 755

netbox_repo:
  git.latest:
    - name: https://github.com/netbox-community/netbox.git
    - target: /opt/netbox
    - branch: main
    - rev: main
    - depth: 1
    - require:
      - file: /opt/netbox

netbox:
  user.present:
    - usergroup: True

/opt/netbox/netbox/media:
  file.directory:
    - user: netbox
    - group: netbox

/opt/netbox/netbox/reports:
  file.directory:
    - user: netbox
    - group: netbox

/opt/netbox/netbox/scripts:
  file.directory:
    - user: netbox
    - group: netbox

/opt/netbox/netbox/netbox/configuration.py:
  file.managed:
    - source: salt://role/netbox/files/configuration.py
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        database_password: {{ database_password }}
        secret_key: {{ secret_key }}

/opt/netbox/gunicorn.py:
  file.managed:
    - source: salt://role/netbox/files/gunicorn.py
    - mode: 644
    - user: root
    - group: root

/etc/systemd/system/netbox-housekeeping.service:
  file.managed:
    - source: salt://role/netbox/files/netbox-housekeeping.service
    - mode: 644
    - user: root
    - group: root

/etc/systemd/system/netbox.service:
  file.managed:
    - source: salt://role/netbox/files/netbox.service
    - mode: 644
    - user: root
    - group: root

/etc/systemd/system/netbox-rq.service:
  file.managed:
    - source: salt://role/netbox/files/netbox-rq.service
    - mode: 644
    - user: root
    - group: root

netbox_service:
  service.running:
    - name: netbox
    - enable: True
    - watch:
      - file: /etc/systemd/system/netbox.service

netbox_rq_service:
  service.running:
    - name: netbox-rq
    - enable: True
    - watch:
      - file: /etc/systemd/system/netbox-rq.service

/etc/nginx/sites-available/netbox:
  file.managed:
    - source: salt://role/netbox/files/netbox
    - mode: 644
    - user: root
    - group: root

/etc/nginx/sites-enabled/default:
  file.absent

/etc/nginx/sites-enabled/netbox:
  file.symlink:
    - target: /etc/nginx/sites-available/netbox

nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - watch:
      - file: /etc/nginx/sites-available/netbox
