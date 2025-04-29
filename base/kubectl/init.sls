kubectl_dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - gnupg

/etc/apt/keyrings/kubernetes-apt-keyring.gpg:
  file.managed:
    - source: salt://base/kubectl/files/kubernetes-apt-keyring.gpg
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

/etc/apt/sources.list.d/kubernetes.list:
  pkgrepo.managed:
    - name: deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /
    - file: /etc/apt/sources.list.d/kubernetes.list
    - require:
      - file: /etc/apt/keyrings/kubernetes-apt-keyring.gpg

kubectl:
  pkg.installed
