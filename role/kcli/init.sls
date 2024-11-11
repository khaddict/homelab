include:
  - base.git
  - base.ansible
  - base.python311_venv
  - base.virtualenv
  - base.kubectl

clone_kubespray:
  git.latest:
    - name: https://github.com/kubernetes-sigs/kubespray.git
    - target: /root/kubespray
    - user: root

setup_venv_kubespray:
  virtualenv.managed:
    - name: /root/kubespray/venv
    - requirements: /root/kubespray/requirements.txt
    - require:
      - git: clone_kubespray

edit_inventory:
  file.managed:
    - name: /root/kubespray/inventory/sample/inventory.ini
    - source: salt://role/kcli/files/inventory.ini
    - mode: 644
    - user: root
    - group: root

edit_addons:
  file.managed:
    - name: /root/kubespray/inventory/sample/group_vars/k8s_cluster/addons.yml
    - source: salt://role/kcli/files/addons.yml
    - mode: 644
    - user: root
    - group: root

edit_k8s_cluster:
  file.managed:
    - name: /root/kubespray/inventory/sample/group_vars/k8s_cluster/k8s-cluster.yml
    - source: salt://role/kcli/files/k8s-cluster.yml
    - mode: 644
    - user: root
    - group: root
