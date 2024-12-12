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
    - source: salt://base/vault/files/hashicorp-archive-keyring.gpg
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
