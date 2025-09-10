{% set fqdn = grains["fqdn"] %}
{% import_yaml 'role/kcontrol/files/keepalived.yaml' as keepalived_data %}

{% set priority = keepalived_data['keepalived'][fqdn]['priority'] %}
{% set state = keepalived_data['keepalived'][fqdn]['state'] %}
{% set virtual_ipaddress = keepalived_data['virtual_ipaddress'] %}

include:
  - base.keepalived

/etc/keepalived/keepalived.conf:
  file.managed:
    - source: salt://role/kcontrol/files/keepalived.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        priority: {{ priority }}
        state: {{ state }}
        virtual_ipaddress: {{ virtual_ipaddress }}

keepalived_service:
  service.running:
    - name: keepalived
    - enable: True
    - reload: True
    - watch:
      - file: /etc/keepalived/keepalived.conf

/etc/sysctl.d/99-kubernetes-net.conf:
  file.managed:
    - source: salt://role/kcontrol/files/99-kubernetes-net.conf
    - mode: 644
    - user: root
    - group: root
