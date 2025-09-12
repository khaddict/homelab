/etc/sysctl.d/99-kubernetes-net.conf:
  file.managed:
    - source: salt://role/kcontrol/files/99-kubernetes-net.conf
    - mode: 644
    - user: root
    - group: root
