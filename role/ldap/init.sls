openldap_dependencies:
  pkg.installed:
    - pkgs:
      - slapd
      - ldap-utils
      - rsyslog
      - phpldapadmin

phpldapadmin_config:
  file.managed:
    - name: /etc/phpldapadmin/config.php
    - source: salt://role/ldap/files/phpldapadmin_config.php
    - mode: 640
    - user: root
    - group: www-data

ldap_config:
  file.managed:
    - name: /etc/ldap/ldap.conf
    - source: salt://role/ldap/files/ldap.conf
    - mode: 644
    - user: root
    - group: root

slapd_logs_conf:
  file.managed:
    - name: /etc/rsyslog.d/10-slapd.conf
    - source: salt://role/ldap/files/10-slapd.conf
    - mode: 644
    - user: root
    - group: root
