/etc/cloud/cloud-init.disabled:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents: ''
    - onlyif: dpkg --list | grep -q '^ii.*cloud-init'
