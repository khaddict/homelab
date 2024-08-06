{% import_yaml 'data/network_confs.yaml' as network_confs %}
{% set fqdn = grains["fqdn"] %}
{% set host = grains["host"] %}

{{ fqdn }}_hosts_conf:
  file.managed:
    - name: /etc/hosts
    - source: salt://global/common/hosts/files/hosts-conf
    - template: jinja
    - context:
        ip_addr: {{ network_confs.network_conf[fqdn].ip_addr }}
        host: {{ host }}
        fqdn: {{ fqdn }}
