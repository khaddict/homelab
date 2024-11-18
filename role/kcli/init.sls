{% set traefik_dashboard_secret_base64 = salt['vault'].read_secret('kv/kubernetes').traefik_dashboard_secret_base64 %}

include:
  - base.git
  - base.ansible
  - base.python311_venv
  - base.virtualenv
  - base.kubectl
  - base.helm

clone_kubespray:
  git.latest:
    - name: https://github.com/kubernetes-sigs/kubespray.git
    - target: /root/kubespray
    - user: root
    - unless: test -d /root/kubespray/.git

setup_venv_kubespray:
  virtualenv.managed:
    - name: /root/kubespray/venv
    - requirements: /root/kubespray/requirements.txt
    - require:
      - git: clone_kubespray

kubespray_homelab_dir:
  file.directory:
    - name: /root/kubespray/inventory/homelab
    - user: root
    - group: root

edit_inventory:
  file.managed:
    - name: /root/kubespray/inventory/homelab/inventory.ini
    - source: salt://role/kcli/files/inventory.ini
    - mode: 644
    - user: root
    - group: root

edit_addons:
  file.managed:
    - name: /root/kubespray/inventory/homelab/group_vars/k8s_cluster/addons.yml
    - source: salt://role/kcli/files/addons.yml
    - mode: 644
    - user: root
    - group: root

edit_k8s_cluster:
  file.managed:
    - name: /root/kubespray/inventory/homelab/group_vars/k8s_cluster/k8s-cluster.yml
    - source: salt://role/kcli/files/k8s-cluster.yml
    - mode: 644
    - user: root
    - group: root

edit_hosts:
  file.managed:
    - name: /root/kubespray/inventory/homelab/hosts.yaml
    - source: salt://role/kcli/files/hosts.yaml
    - mode: 644
    - user: root
    - group: root

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
