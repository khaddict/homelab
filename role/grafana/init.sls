{% set oscodename = grains["oscodename"] %}

grafana_dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - software-properties-common
      - wget

/etc/apt/keyrings/grafana.gpg:
  file.managed:
    - source: salt://role/grafana/files/grafana.gpg
    - mode: 644
    - user: root
    - group: root

/etc/apt/sources.list.d/grafana.list:
  pkgrepo.managed:
    - name: deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main
    - file: /etc/apt/sources.list.d/grafana.list
    - require:
      - file: /etc/apt/keyrings/grafana.gpg

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
