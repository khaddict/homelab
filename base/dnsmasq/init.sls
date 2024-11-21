{% import_yaml 'data/network_confs.yaml' as network_confs %}
{% set powerdns_recursor = network_confs.dns_nameservers['powerdns_recursor'] %}
{% set freebox = network_confs.dns_nameservers['freebox'] %}

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