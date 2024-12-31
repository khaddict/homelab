{% set oscodename = grains["oscodename"] %}

sources_config:
  file.managed:
    - name: /etc/apt/sources.list
{% if grains["os"] == "Debian" %}
    - source: salt://global/common/sources/files/debian_sources.list
{% elif grains["os"] == "Ubuntu" %}
    - source: salt://global/common/sources/files/ubuntu_sources.list
{% endif %}
    - template: jinja
    - context:
        oscodename: {{ oscodename }}

homelab_aptly_config:
  file.managed:
    - name: /etc/apt/sources.list.d/homelab_aptly.list
    - source: salt://global/common/sources/files/homelab_aptly.list
    - mode: 644
    - user: root
    - group: root

apt_update:
  cmd.wait:
    - name: apt-get update
    - watch:
        - file: /etc/apt/sources.list
        - file: /etc/apt/sources.list.d/homelab_aptly.list
    - require:
        - file: sources_config
        - file: homelab_aptly_config
