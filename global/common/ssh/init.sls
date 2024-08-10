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

remove_symlink_if_present:
  cmd.run:
    - name: unlink /root/.ssh/authorized_keys
    - onlyif: test -L /root/.ssh/authorized_keys

authorized_keys_file:
  file.managed:
    - name: /root/.ssh/authorized_keys
    - source: salt://global/common/ssh/files/authorized_keys
    - mode: 600
    - user: root
    - group: root
    - template: jinja
    - context:
        fqdn: {{ fqdn }}
    - require:
      - cmd: remove_symlink_if_present

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
