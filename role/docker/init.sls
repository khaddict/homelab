manage_docker_asc:
  file.managed:
    - name: /etc/apt/keyrings/docker.asc
    - source: salt://role/docker/files/docker.asc
    - mode: 644
    - user: root
    - group: root

docker_repo_pkg:
  pkgrepo.managed:
    - name: deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable
    - file: /etc/apt/sources.list.d/docker.list
    - require:
      - file: manage_docker_asc

install_docker:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
