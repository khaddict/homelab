/etc/apt/keyrings/docker.asc:
  file.managed:
    - source: salt://role/docker/files/docker.asc
    - mode: 644
    - user: root
    - group: root

/etc/apt/sources.list.d/docker.list:
  pkgrepo.managed:
    - name: deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable
    - file: /etc/apt/sources.list.d/docker.list
    - require:
      - file: /etc/apt/keyrings/docker.asc

install_docker:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
