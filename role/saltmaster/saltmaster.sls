include:
  - base.saltstack

saltgui_directory:
  file.recurse:
    - name: /srv/saltgui
    - source: salt://role/saltmaster/files/saltgui
    - include_empty: True

master_config:
  file.managed:
    - name: /etc/salt/master
    - source: salt://role/saltmaster/files/master
    - mode: 644
    - user: root
    - group: root

saltgui_user:
  user.present:
    - name: saltgui
    - usergroup: True
    - createhome: False

install_salt_master:
  pkg.installed:
    - name: salt-master

service_salt_master:
  service.running:
    - name: salt-master
    - enable: True
    - require:
      - pkg: install_salt_master

install_salt_ssh:
  pkg.installed:
    - name: salt-ssh

install_salt_syndic:
  pkg.installed:
    - name: salt-syndic

stop_salt_syndic:
  service.dead:
    - name: salt-syndic
    - enable: False

install_salt_cloud:
  pkg.installed:
    - name: salt-cloud

install_salt_api:
  pkg.installed:
    - name: salt-api

service_salt_api:
  service.running:
    - name: salt-api
    - enable: True
    - require:
      - pkg: install_salt_api
