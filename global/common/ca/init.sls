/usr/local/share/ca-certificates/homelab.chain.crt:
  file.managed:
    - source: salt://global/common/ca/files/homelab.chain.crt
    - mode: 644
    - user: root
    - group: root

update-certificates:
  cmd.run :
    - name: /usr/sbin/update-ca-certificates
    - onchanges:
      - /usr/local/share/ca-certificates/homelab.chain.crt
