apt-transport-https:
  pkg.installed

/etc/apt/keyrings/helm.gpg:
  file.managed:
    - source: salt://base/helm/files/helm.gpg
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

/etc/apt/sources.list.d/helm-stable-debian.list:
  pkgrepo.managed:
    - name: deb [arch=amd64 signed-by=/etc/apt/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main
    - file: /etc/apt/sources.list.d/helm-stable-debian.list
    - require:
      - file: /etc/apt/keyrings/helm.gpg

helm:
  pkg.installed
