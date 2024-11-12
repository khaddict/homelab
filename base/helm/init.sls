helm_dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https

helm_gpg_key:
  file.managed:
    - name: /etc/apt/keyrings/helm.gpg
    - source: salt://base/helm/files/helm.gpg
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

helm_repo_pkg:
  pkgrepo.managed:
    - name: deb [arch=amd64 signed-by=/etc/apt/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main
    - file: /etc/apt/sources.list.d/helm-stable-debian.list
    - require:
      - file: helm_gpg_key

install_helm:
  pkg.installed:
    - name: helm
