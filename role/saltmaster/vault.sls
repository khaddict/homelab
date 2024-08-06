{% set salt_policy_token = salt['vault'].read_secret('kv/vault_tokens').salt_policy_token %}

vault_config:
  file.managed:
    - name: /etc/salt/master.d/vault.conf
    - source: salt://role/saltmaster/files/vault.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        salt_policy_token: {{ salt_policy_token }}

peer_run_config:
  file.managed:
    - name: /etc/salt/master.d/peer_run.conf
    - source: salt://role/saltmaster/files/peer_run.conf
    - mode: 644
    - user: root
    - group: root

reload_service_salt_master:
  service.running:
    - name: salt-master
    - enable: True
    - reload: True
    - watch:
      - file: vault_config
      - file: peer_run_config
