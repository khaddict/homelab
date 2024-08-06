{% import_yaml 'data/network_confs.yaml' as network_confs %}
{% set powerdns = network_confs.dns_nameservers['powerdns'] %}
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
        powerdns: {{ powerdns }}
        freebox: {{ freebox }}
    - require:
      - pkg: install_dnsmasq