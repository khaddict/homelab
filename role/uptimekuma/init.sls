/root/.bashrc.d/uptimekuma.bashrc:
  file.managed:
    - source: salt://role/uptimekuma/files/uptimekuma.bashrc
    - mode: 644
    - user: root
    - group: root
