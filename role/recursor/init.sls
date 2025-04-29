{% import_json 'data/main.json' as data %}

{% set powerdns_authoritative = data.network.dns_nameservers.powerdns_authoritative %}

pdns-recursor:
  pkg.installed

/etc/powerdns/recursor.conf:
  file.managed:
    - source: salt://role/recursor/files/recursor.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        powerdns_authoritative: {{ powerdns_authoritative }}
    - require:
      - pkg: pdns-recursor

pdns_recursor_service:
  service.running:
    - name: pdns-recursor
    - enable: True
    - require:
      - file: /etc/powerdns/recursor.conf
    - watch:
      - file: /etc/powerdns/recursor.conf