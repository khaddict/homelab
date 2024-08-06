{% set osarch = grains["osarch"] %}
{% set oscodename = grains["oscodename"] %}

vault_dependencies:
  pkg.installed:
    - pkgs:
      - gpg
      - wget

manage_hashicorp_gpg:
  file.managed:
    - name: /usr/share/keyrings/hashicorp-archive-keyring.gpg
    - source: salt://role/vault/files/hashicorp-archive-keyring.gpg
    - mode: 644
    - user: root
    - group: root

vault_repo_pkg:
  pkgrepo.managed:
    - name: deb [arch={{ osarch }} signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com {{ oscodename }} main
    - dist: {{ oscodename }}
    - file: /etc/apt/sources.list.d/hashicorp.list
    - require:
      - file: manage_hashicorp_gpg

install_vault:
  pkg.installed:
    - name: vault

vault_config:
  file.managed:
    - name: /etc/vault.d/vault.hcl
    - source: salt://role/vault/files/vault.hcl
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: install_vault

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
