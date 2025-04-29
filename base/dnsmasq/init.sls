{% import_json 'data/main.json' as data %}
{% set powerdns_recursor = data.network.dns_nameservers.powerdns_recursor %}
{% set freebox = data.network.dns_nameservers.freebox %}

dnsmasq:
  pkg.installed

/etc/dnsmasq.conf:
  file.managed:
    - source: salt://base/dnsmasq/files/dnsmasq.conf
    - makedirs: True
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        powerdns_recursor: {{ powerdns_recursor }}
        freebox: {{ freebox }}
    - require:
      - pkg: dnsmasq
