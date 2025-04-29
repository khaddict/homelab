include:
  - base.chrony

stop_systemd_timesyncd:
  service.dead:
    - name: systemd-timesyncd
    - enable: False

{% if grains["fqdn"] != "ntp.homelab.lan" %}
/etc/chrony/chrony.conf:
  file.managed:
    - source: salt://global/common/ntp/files/chrony.conf
    - mode: 644
    - user: root
    - group: root
{% endif %}

service_chrony_client:
  service.running:
    - name: chrony
    - enable: True
{% if grains["fqdn"] != "ntp.homelab.lan" %}
    - watch:
      - file: /etc/chrony/chrony.conf
{% endif %}
