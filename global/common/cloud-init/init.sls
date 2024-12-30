disable_cloud_init:
  file.managed:
    - name: /etc/cloud/cloud-init.disabled
    - mode: 644
    - user: root
    - group: root
    - contents: ''
    - onlyif: dpkg --list | grep -q '^ii.*cloud-init'
