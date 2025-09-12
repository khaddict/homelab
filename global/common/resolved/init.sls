{% import_json 'data/main.json' as data %}

{% set powerdns_authoritative = data.network.dns_nameservers.powerdns_authoritative %}
{% set freebox = data.network.dns_nameservers.freebox %}

/etc/systemd/resolved.conf:
  file.managed:
    - source: salt://global/common/resolved/files/resolved.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        powerdns_authoritative: {{ powerdns_authoritative }}
        freebox: {{ freebox }}
