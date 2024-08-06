{% import_yaml 'data/network_confs.yaml' as network_confs %}
{% set fqdn = grains["fqdn"] %}

{{ fqdn }}_resolv_conf:
  file.managed:
    - name: /etc/resolv.conf
    - source: salt://global/common/resolv/files/resolv-conf
    - template: jinja
    - context:
        dns_nameservers: {{ network_confs.dns_nameservers }}
        fqdn: {{ fqdn }}
