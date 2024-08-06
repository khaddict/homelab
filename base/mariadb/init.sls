mariadb_dependencies:
  pkg.installed:
    - pkgs:
      - software-properties-common
      - gnupg2

download_mariadb_script:
  file.managed:
    - name: /tmp/mariadb_repo_setup
    - source: https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
    - skip_verify: True
    - require:
      - pkg: mariadb_dependencies

execute_mariadb_script:
  cmd.run :
    - name: /usr/bin/bash /tmp/mariadb_repo_setup
    - require:
      - file: download_mariadb_script
    - onchanges:
      - download_mariadb_script

install_mariadb:
  pkg.installed:
    - pkgs:
      - mariadb-server
      - mariadb-client
    - require:
      - cmd: execute_mariadb_script

service_mariadb:
  service.running:
    - name: mariadb
    - enable: True
    - require:
      - pkg: install_mariadb
