{% set oscodename = grains["oscodename"] %}

grafana_dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - software-properties-common
      - wget

/usr/share/keyrings/grafana.key:
  file.managed:
    - source: salt://role/grafana/files/grafana.key
    - mode: 644
    - user: root
    - group: root

/etc/apt/sources.list.d/grafana.list:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main
    - file: /etc/apt/sources.list.d/grafana.list
    - require:
      - file: /usr/share/keyrings/grafana.key

grafana:
  pkg.installed

/etc/grafana/ldap.toml:
  file.managed:
    - source: salt://role/grafana/files/ldap.toml
    - mode: 640
    - user: root
    - group: grafana

/etc/grafana/grafana.ini:
  file.managed:
    - source: salt://role/grafana/files/grafana.ini
    - mode: 640
    - user: root
    - group: grafana

service_grafana:
  service.running:
    - name: grafana-server
    - enable: True
    - require:
      - pkg: grafana
    - watch:
      - file: /etc/grafana/ldap.toml
      - file: /etc/grafana/grafana.ini
