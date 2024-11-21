{% import_yaml 'data/network_confs.yaml' as network_confs %}
{% set fqdn = grains["fqdn"] %}
{% set host = grains["host"] %}

{% if fqdn in network_confs.network_conf %}
{{ fqdn }}_hosts_conf:
  file.managed:
    - name: /etc/hosts
    - source: salt://global/common/hosts/files/hosts
    - template: jinja
    - context:
        ip_addr: {{ network_confs.network_conf[fqdn].ip_addr }}
        host: {{ host }}
        fqdn: {{ fqdn }}
{% else %}
hosts_conf_absent_warning:
  test.show_notification:
    - text: "COMPLETE THE NETWORK CONFIGURATION FOR {{ fqdn }} IN DATA/NETWORK_CONFS.YAML"
{% endif %}
