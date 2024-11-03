salt_pgp_key:
  file.managed:
    - name: /etc/apt/keyrings/salt-archive-keyring.pgp
    - source: salt://base/saltstack/files/salt-archive-keyring.pgp
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

salt_sources:
  file.managed:
    - name: /etc/apt/sources.list.d/salt.sources
    - source: salt://base/saltstack/files/salt.sources
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
