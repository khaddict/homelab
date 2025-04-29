openldap_dependencies:
  pkg.installed:
    - pkgs:
      - slapd
      - ldap-utils
      - rsyslog
      - phpldapadmin

/etc/phpldapadmin/config.php:
  file.managed:
    - source: salt://role/ldap/files/phpldapadmin_config.php
    - mode: 640
    - user: root
    - group: www-data

/etc/ldap/ldap.conf:
  file.managed:
    - source: salt://role/ldap/files/ldap.conf
    - mode: 644
    - user: root
    - group: root

/etc/rsyslog.d/10-slapd.conf:
  file.managed:
    - source: salt://role/ldap/files/10-slapd.conf
    - mode: 644
    - user: root
    - group: root
