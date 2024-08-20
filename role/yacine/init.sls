{% set github_commits_iacine_webhook_url = salt['vault'].read_secret('kv/main').github_commits_iacine_webhook_url %}

github_commits_script:
  file.managed:
    - name: /root/github_commits/github_commits.sh
    - source: salt://role/yacine/files/github_commits.sh
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - context:
        github_commits_iacine_webhook_url: {{ github_commits_iacine_webhook_url }}

github_commits_service:
  file.managed:
    - name: /etc/systemd/system/github_commits.service
    - source: salt://role/yacine/files/github_commits.service
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: github_commits_script
    - watch:
      - file: github_commits_script

github_commits_timer:
  file.managed:
    - name: /etc/systemd/system/github_commits.timer
    - source: salt://role/yacine/files/github_commits.timer
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: github_commits_script
    - watch:
      - file: github_commits_script
