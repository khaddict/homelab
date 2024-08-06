{% set oscodename = grains["oscodename"] %}

grafana_dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - software-properties-common
      - wget

manage_grafana_key:
  file.managed:
    - name: /usr/share/keyrings/grafana.key
    - source: salt://role/grafana/files/grafana.key
    - mode: 644
    - user: root
    - group: root

grafana_repo_pkg:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main
    - file: /etc/apt/sources.list.d/grafana.list
    - require:
      - file: manage_grafana_key

install_grafana:
  pkg.installed:
    - name: grafana

ldap_config:
  file.managed:
    - name: /etc/grafana/ldap.toml
    - source: salt://role/grafana/files/ldap.toml
    - mode: 640
    - user: root
    - group: grafana

grafana_config:
  file.managed:
    - name: /etc/grafana/grafana.ini
    - source: salt://role/grafana/files/grafana.ini
    - mode: 640
    - user: root
    - group: grafana

service_grafana:
  service.running:
    - name: grafana-server
    - enable: True
    - require:
      - pkg: install_grafana
    - watch:
      - file: ldap_config
      - file: grafana_config