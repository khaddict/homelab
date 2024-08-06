bashrc_file:
  file.managed:
    - name: /root/.bashrc
    - source: salt://global/common/bashrc/files/.bashrc
    - mode: 644
    - user: root
    - group: root

bashrc_directory:
  file.recurse:
    - name: /root/.bashrc.d
    - source: salt://global/common/bashrc/files/.bashrc.d
    - include_empty: True
