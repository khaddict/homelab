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

stop_salt_syndic:
  service.dead:
    - name: salt-syndic
    - enable: False
