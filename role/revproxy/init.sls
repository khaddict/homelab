{% set fqdn = grains["fqdn"] %}

include:
  - base.haproxy

/etc/haproxy/haproxy.cfg:
  file.managed:
    - source: salt://role/revproxy/files/haproxy.cfg
    - mode: 644
    - user: root
    - group: root

haproxy_service:
  service.running:
    - name: haproxy
    - enable: True
    - reload: True
    - watch:
      - file: /etc/haproxy/haproxy.cfg
