include:
  - base.chrony

stop_systemd_timesyncd:
  service.dead:
    - name: systemd-timesyncd
    - enable: False

{% if grains["fqdn"] != "ntp.homelab.lan" %}
chrony_client_config:
  file.managed:
    - name: /etc/chrony/chrony.conf
    - source: salt://global/common/ntp/files/chrony.conf
    - mode: 644
    - user: root
    - group: root
{% endif %}

enable_service_chrony_client:
  service.running:
    - name: chrony
    - enable: True
{% if grains["fqdn"] != "ntp.homelab.lan" %}
    - watch:
      - file: chrony_client_config
{% endif %}
