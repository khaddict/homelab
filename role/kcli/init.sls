{% set vault_token = salt['vault'].read_secret('kv/kubernetes').vault_token %}

include:
  - base.git
  - base.ansible
  - base.python311_venv
  - base.virtualenv
  - base.kubectl
  - base.helm
  - base.vault
  - base.apache2_utils

kubespray_directory:
  file.recurse:
    - name: /root/kubespray
    - source: salt://role/kcli/files/kubespray
    - include_empty: True

kcli_bashrc:
  file.managed:
    - name: /root/.bashrc.d/kcli.bashrc
    - source: salt://role/kcli/files/kcli.bashrc
    - mode: 644
    - user: root
    - group: root

apps_directory:
  file.recurse:
    - name: /root/apps
    - source: salt://role/kcli/files/apps
    - include_empty: True

scripts_directory:
  file.recurse:
    - name: /root/scripts
    - source: salt://role/kcli/files/scripts
    - include_empty: True
    - template: jinja
    - context:
        vault_token: {{ vault_token }}

clone_homelab_cloud:
  git.latest:
    - name: https://github.com/khaddict/homelab_cloud.git
    - target: /root/homelab_cloud
    - user: root
    - force_reset: True
    - force_fetch: True
