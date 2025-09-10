include:
  - base.saltstack
  - role.saltmaster.service_salt_master

/srv/saltgui:
  file.recurse:
    - source: salt://role/saltmaster/files/saltgui
    - include_empty: True

/etc/salt/master:
  file.managed:
    - source: salt://role/saltmaster/files/master
    - mode: 644
    - user: salt
    - group: salt

/etc/apt/preferences.d/salt.pref:
  file.managed:
    - source: salt://role/saltmaster/files/salt.pref
    - mode: 644
    - user: root
    - group: root

saltgui:
  user.present:
    - usergroup: True
    - createhome: False

salt-master:
  pkg.installed

salt-ssh:
  pkg.installed

salt-syndic:
  pkg.installed

service_salt_syndic:
  service.dead:
    - name: salt-syndic
    - enable: False

salt-cloud:
  pkg.installed

salt-api:
  pkg.installed

service_salt_api:
  service.running:
    - name: salt-api
    - enable: True
    - require:
      - pkg: salt-api
