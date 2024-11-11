kubectl_dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - gnupg

kubernetes_gpg_key:
  file.managed:
    - name: /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    - source: salt://base/kubectl/files/kubernetes-apt-keyring.gpg
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

kubernetes_repo_pkg:
  pkgrepo.managed:
    - name: deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /
    - file: /etc/apt/sources.list.d/kubernetes.list
    - require:
      - file: kubernetes_gpg_key

install_kubectl:
  pkg.installed:
    - name: kubectl
