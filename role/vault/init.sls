include:
  - base.vault

vault_config:
  file.managed:
    - name: /etc/vault.d/vault.hcl
    - source: salt://role/vault/files/vault.hcl
    - mode: 644
    - user: root
    - group: root

vault_service:
  file.managed:
    - name: /etc/systemd/system/vault.service
    - source: salt://role/vault/files/vault.service
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: vault_config

start_enable_vault_service:
  service.running:
    - name: vault
    - enable: True
    - require:
      - file: vault_service

vault_bashrc:
  file.managed:
    - name: /root/.bashrc.d/vault.bashrc
    - source: salt://role/vault/files/vault.bashrc
    - mode: 644
    - user: root
    - group: root
