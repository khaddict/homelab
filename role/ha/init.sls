{% set fqdn = grains["fqdn"] %}
{% set ha_iface = 'enp0s11' %}
{% set vip = '192.168.0.214' %}
{% set host = grains["host"] %}

include:
  - base.haproxy
  - base.keepalived

haproxy_config:
  file.managed:
    - name: /etc/haproxy/haproxy.cfg
    - source: salt://role/ha/files/haproxy.cfg
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        host: {{ host }}

restart_haproxy_service:
  service.running:
    - name: haproxy
    - enable: True
    - reload: True
    - watch:
      - file: haproxy_config

remove_keepalived_default:
  file.absent:
    - name: /etc/keepalived/keepalived.conf.sample

keepalived_config:
  file.managed:
    - name: /etc/keepalived/keepalived.conf
    - source: salt://role/ha/files/keepalived.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        fqdn: {{ fqdn }}
        ha_iface: {{ ha_iface }}
        vip: {{ vip }}

restart_keepalived_service:
  service.running:
    - name: keepalived
    - enable: True
    - reload: True
    - watch:
      - file: keepalived_config
