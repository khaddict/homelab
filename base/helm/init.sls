apt-transport-https:
  pkg.installed

/usr/share/keyrings/helm.gpg:
  file.managed:
    - source: salt://base/helm/files/helm.gpg
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

/etc/apt/sources.list.d/helm-stable-debian.list:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main
    - file: /etc/apt/sources.list.d/helm-stable-debian.list
    - require:
      - file: /usr/share/keyrings/helm.gpg

helm:
  pkg.installed
