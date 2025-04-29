service_salt_master:
  service.running:
    - name: salt-master
    - enable: True
    - require:
      - pkg: salt-master
