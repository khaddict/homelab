{% set admin_api_key = salt['vault'].read_secret('kv/powerdns').admin_api_key %}
{% set login_webhook_url = salt['vault'].read_secret('kv/main').login_webhook_url %}
{% set pull_webhook_url = salt['vault'].read_secret('kv/main').pull_webhook_url %}
{% set github_commits_khaddict_webhook_url = salt['vault'].read_secret('kv/main').github_commits_khaddict_webhook_url %}
{% set github_pull_token = salt['vault'].read_secret('kv/main').github_pull_token %}
{% import_json 'data/main.json' as data %}
{% set proxmox_nodes = data.proxmox_nodes.keys() | list %}
{% set proxmox_vms = data.proxmox_vms | map(attribute='vm_name') | list %}
{% set hosts_list = proxmox_nodes + proxmox_vms %}

include:
  - base.pssh
  - base.age

/root/.bashrc.d/vars.bashrc:
  file.managed:
    - source: salt://role/main/files/vars.bashrc
    - mode: 700
    - user: root
    - group: root
    - template: jinja
    - context:
        admin_api_key: {{ admin_api_key }}

/root/login/login.sh:
  file.managed:
    - source: salt://role/main/files/login.sh
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - context:
        login_webhook_url: {{ login_webhook_url }}

/etc/systemd/system/login.service:
  file.managed:
    - source: salt://role/main/files/login.service
    - mode: 644
    - user: root
    - group: root

login_service:
  service.running:
    - name: login
    - enable: True
    - watch:
      - file: /etc/systemd/system/login.service

/root/github_pull/github_pull.sh:
  file.managed:
    - source: salt://role/main/files/github_pull.sh
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - context:
        github_pull_token: {{ github_pull_token }}
        pull_webhook_url: {{ pull_webhook_url }}

/etc/systemd/system/github_pull.service:
  file.managed:
    - source: salt://role/main/files/github_pull.service
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: /root/github_pull/github_pull.sh
    - watch:
      - file: /root/github_pull/github_pull.sh

/etc/systemd/system/github_pull.timer:
  file.managed:
    - source: salt://role/main/files/github_pull.timer
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: /root/github_pull/github_pull.sh
    - watch:
      - file: /root/github_pull/github_pull.sh

/root/pssh/pssh_all_hosts:
  file.managed:
    - source: salt://role/main/files/pssh_all_hosts
    - makedirs: True
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        hosts_list: {{ hosts_list }}

/root/pssh/pssh_hosts:
  file.managed:
    - source: salt://role/main/files/pssh_hosts
    - makedirs: True
    - mode: 644
    - user: root
    - group: root
