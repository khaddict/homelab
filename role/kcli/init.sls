include:
  - base.git
  - base.ansible

clone_kubespray:
  git.latest:
    - name: https://github.com/kubernetes-sigs/kubespray.git
    - target: /root/kubespray
    - user: root
