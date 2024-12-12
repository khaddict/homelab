{% set traefik_dashboard_secret_base64 = salt['vault'].read_secret('kv/kubernetes').traefik_dashboard_secret_base64 %}
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

manifests_directory:
  file.recurse:
    - name: /root/manifests
    - source: salt://role/kcli/files/manifests
    - include_empty: True
    - template: jinja
    - context:
        traefik_dashboard_secret_base64: {{ traefik_dashboard_secret_base64 }}

scripts_directory:
  file.recurse:
    - name: /root/scripts
    - source: salt://role/kcli/files/scripts
    - include_empty: True
    - template: jinja
    - context:
        vault_token: {{ vault_token }}
