{% set fqdn = grains["fqdn"] %}

install_ssh:
  pkg.installed:
    - name: openssh-server

sshd_config:
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://global/common/ssh/files/sshd_config
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        fqdn: {{ fqdn }}

authorized_keys_file:
  file.managed:
    {% if fqdn is match('n\d-cls\d\.homelab\.lan') %}
    - name: /etc/pve/priv/authorized_keys
    - group: www-data
    {% else %}
    - name: /root/.ssh/authorized_keys
    - group: root
    {% endif %}
    - source: salt://global/common/ssh/files/authorized_keys
    - mode: 600
    - user: root
    - template: jinja
    - context:
        fqdn: {{ fqdn }}

ssh_config_file:
  file.managed:
    - name: /root/.ssh/config
    - source: salt://global/common/ssh/files/config
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        fqdn: {{ fqdn }}

reload_service_ssh:
  service.running:
    - name: ssh
    - enable: True
    - reload: True
    - watch:
      - file: sshd_config
      - file: authorized_keys_file
      - file: ssh_config_file
