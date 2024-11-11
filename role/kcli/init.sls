include:
  - base.git
  - base.ansible
  - base.python311_venv

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
