{% set vault_token = salt['vault'].read_secret('kv/kubernetes').vault_token %}

include:
  - base.git
  - base.ansible
  - base.python313_venv
  - base.virtualenv
  - base.kubectl
  - base.helm
  - base.vault
  - base.apache2_utils

/root/kubespray:
  file.recurse:
    - source: salt://role/kcli/files/kubespray
    - include_empty: True

/root/.bashrc.d/kcli.bashrc:
  file.managed:
    - source: salt://role/kcli/files/kcli.bashrc
    - mode: 644
    - user: root
    - group: root

/root/apps:
  file.recurse:
    - source: salt://role/kcli/files/apps
    - include_empty: True

/root/scripts:
  file.recurse:
    - source: salt://role/kcli/files/scripts
    - include_empty: True
    - template: jinja
    - context:
        vault_token: {{ vault_token }}

https://github.com/khaddict/homelab_cloud.git:
  git.latest:
    - target: /root/homelab_cloud
    - user: root
    - force_reset: True
    - force_fetch: True
