{% import_json 'data/main.json' as data %}
{% set powerdns_recursor = data.network.dns_nameservers.powerdns_recursor %}
{% set freebox = data.network.dns_nameservers.freebox %}

install_dnsmasq:
  pkg.installed:
    - name: dnsmasq

dnsmasq_config:
  file.managed:
    - name: /etc/dnsmasq.conf
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
      - pkg: install_dnsmasq
