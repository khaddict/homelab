install_ca_certificate:
  file.managed:
    - name: /usr/local/share/ca-certificates/ca-homelab.crt
    - source: salt://global/common/ca/files/ca-homelab.crt
    - mode: 644
    - user: root
    - group: root

update-certificates:
  cmd.run :
    - name: /usr/sbin/update-ca-certificates
    - onchanges:
      - install_ca_certificate
