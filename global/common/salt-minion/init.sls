{% set osarch = grains["osarch"] %}
{% set osrelease = grains["osrelease"] %}
{% set oscodename = grains["oscodename"] %}
{% set os = grains["os"] | lower %}

minion_config:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://global/common/salt-minion/files/minion
    - mode: 644
    - user: root
    - group: root

download_salt_gpg_key:
  file.managed:
    - name: /etc/apt/keyrings/salt-archive-keyring-2023.gpg
    - source: https://repo.saltproject.io/salt/py3/{{ os }}/{{ osrelease }}/{{ osarch }}/SALT-PROJECT-GPG-PUBKEY-2023.gpg
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
    - skip_verify: True

salt_repo_pkg:
  pkgrepo.managed:
    - name: deb [arch={{ osarch }} signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg] https://repo.saltproject.io/salt/py3/{{ os }}/{{ osrelease }}/{{ osarch }}/latest {{ oscodename }} main
    - dist: {{ oscodename }}
    - file: /etc/apt/sources.list.d/salt.list
    - require:
      - file: download_salt_gpg_key

install_salt_minion:
  pkg.installed:
    - name: salt-minion

service_salt_minion:
  service.running:
    - name: salt-minion
    - enable: True
