{% set oscodename = grains["oscodename"] %}

/etc/apt/sources.list:
  file.managed:
{% if grains["os"] == "Debian" %}
    - source: salt://global/common/sources/files/debian_sources.list
{% elif grains["os"] == "Ubuntu" %}
    - source: salt://global/common/sources/files/ubuntu_sources.list
{% endif %}
    - template: jinja
    - context:
        oscodename: {{ oscodename }}

/etc/apt/sources.list.d/homelab_aptly.list:
  file.managed:
    - source: salt://global/common/sources/files/homelab_aptly.list
    - mode: 644
    - user: root
    - group: root

{% if grains["fqdn"] is match('n\d-cls\d\.homelab\.lan') %}
/etc/apt/sources.list.d/proxmox.list:
  file.managed:
    - source: salt://global/common/sources/files/proxmox.list
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        oscodename: {{ oscodename }}
{%- endif %}

apt_update:
  cmd.wait:
    - name: apt update
    - watch:
        - file: /etc/apt/sources.list
        - file: /etc/apt/sources.list.d/homelab_aptly.list
        {% if grains["fqdn"] is match('n\d-cls\d\.homelab\.lan') %}
        - file: /etc/apt/sources.list.d/proxmox.list
        {%- endif %}
    - require:
        - file: /etc/apt/sources.list
        - file: /etc/apt/sources.list.d/homelab_aptly.list
        {% if grains["fqdn"] is match('n\d-cls\d\.homelab\.lan') %}
        - file: /etc/apt/sources.list.d/proxmox.list
        {%- endif %}
