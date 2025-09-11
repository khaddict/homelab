{% set salt_policy_token = salt['vault'].read_secret('kv/vault_tokens').salt_policy_token %}

/etc/salt/master.d/vault.conf:
  file.managed:
    - source: salt://role/saltmaster/files/vault.conf
    - mode: 644
    - user: salt
    - group: salt
    - template: jinja
    - context:
        salt_policy_token: {{ salt_policy_token }}
    - watch_in:
      - service: service_salt_master

/etc/salt/master.d/peer_run.conf:
  file.managed:
    - source: salt://role/saltmaster/files/peer_run.conf
    - mode: 644
    - user: salt
    - group: salt
    - watch_in:
      - service: service_salt_master
