{% set ldap_password = salt['vault'].read_secret('kv/ldap').proxmox_pass %}
{% set shadowdrive_user = salt['vault'].read_secret('kv/proxmox').shadowdrive_user %}
{% set shadowdrive_password = salt['vault'].read_secret('kv/proxmox').shadowdrive_password %}
{% set fqdn = grains["fqdn"] %}
{% set host = grains["host"] %}

include:
  - base.davfs2

user_cfg_file:
  file.managed:
    - name: /etc/pve/user.cfg
    - source: salt://role/proxmox/files/user.cfg
    - user: root
    - group: www-data
    - mode: 640
    - makedirs: True

domains_cfg_file:
  file.managed:
    - name: /etc/pve/domains.cfg
    - source: salt://role/proxmox/files/domains.cfg
    - user: root
    - group: www-data
    - mode: 640
    - makedirs: True

ldap_pw_file:
  file.managed:
    - name: /etc/pve/priv/ldap/ldap.pw
    - source: salt://role/proxmox/files/ldap.pw
    - user: root
    - group: www-data
    - mode: 600
    - makedirs: True
    - template: jinja
    - context:
        ldap_password: {{ ldap_password }}

shadowdrive_directory:
  file.directory:
    - name: /mnt/shadowdrive
    - mode: 755
    - user: root
    - group: root
    - makedirs: True

shadowdrive_secrets:
  file.managed:
    - name: /etc/davfs2/secrets
    - source: salt://role/proxmox/files/secrets
    - user: root
    - group: root
    - mode: 600
    - makedirs: True
    - template: jinja
    - context:
        shadowdrive_user: {{ shadowdrive_user }}
        shadowdrive_password: {{ shadowdrive_password }}

add_fstab_entry:
  file.append:
    - name: /etc/fstab
    - text: "https://drive.shadow.tech/remote.php/webdav /mnt/shadowdrive davfs rw,user,_netdev 0 0"
    - unless: grep -q "https://drive.shadow.tech/remote.php/webdav /mnt/shadowdrive davfs rw,user,_netdev 0 0" /etc/fstab

davfs2_config:
  file.managed:
    - name: /etc/davfs2/davfs2.conf
    - source: salt://role/proxmox/files/davfs2.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
