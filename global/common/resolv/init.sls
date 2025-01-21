{% import_json 'data/main.json' as data %}
{% set fqdn = grains["fqdn"] %}

replace_resolv_conf:
  file.absent:
    - name: /etc/resolv.conf
    - onlyif: test -L /etc/resolv.conf

{{ fqdn }}_resolv_conf:
  file.managed:
    - name: /etc/resolv.conf
    - source: salt://global/common/resolv/files/resolv-conf
    - template: jinja
    - context:
        dns_nameservers: {{ data.network.dns_nameservers }}
        fqdn: {{ fqdn }}
    - require:
      - file: replace_resolv_conf

disable_systemd_resolved:
  service.disabled:
    - name: systemd-resolved
    - enable: False
    - require:
      - file: replace_resolv_conf

stop_systemd_resolved:
  service.dead:
    - name: systemd-resolved
    - require:
      - service: disable_systemd_resolved
