{% import_yaml 'data/network_confs.yaml' as network_confs %}

{% set powerdns_authoritative = network_confs.dns_nameservers['powerdns_authoritative'] %}

install_pdns_recursor:
  pkg.installed:
    - name: pdns-recursor

pdns_recursor_config:
  file.managed:
    - name: /etc/powerdns/recursor.conf
    - source: salt://role/recursor/files/recursor.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        powerdns_authoritative: {{ powerdns_authoritative }}
    - require:
      - pkg: install_pdns_recursor

pdns_recursor_service:
  service.running:
    - name: pdns-recursor
    - enable: True
    - require:
      - file: pdns_recursor_config
    - watch:
      - file: pdns_recursor_config