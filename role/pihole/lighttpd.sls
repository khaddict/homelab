{% set fqdn = grains["fqdn"] %}

install_lighttpd_mod_openssl:
  pkg.installed:
    - name: lighttpd-mod-openssl

20_pihole_external_config:
  file.managed:
    - name: /etc/lighttpd/conf-available/20-pihole-external.conf
    - source: salt://role/pihole/files/20-pihole-external.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        fqdn: {{ fqdn }}
    - require:
      - pkg: install_lighttpd_mod_openssl

20_pihole_external_symlink:
  file.symlink:
    - name: /etc/lighttpd/conf-enabled/20-pihole-external.conf
    - target: /etc/lighttpd/conf-available/20-pihole-external.conf
    - require:
      - file: 20_pihole_external_config

reload_lighttpd_service:
  service.running:
    - name: lighttpd
    - enable: True
    - reload: True
    - watch:
      - file: 20_pihole_external_config
