{% set xpack_encryptedSavedObjects_encryptionKey = salt['vault'].read_secret('kv/elk').xpack_encryptedSavedObjects_encryptionKey %}
{% set xpack_reporting_encryptionKey = salt['vault'].read_secret('kv/elk').xpack_reporting_encryptionKey %}
{% set xpack_security_encryptionKey = salt['vault'].read_secret('kv/elk').xpack_security_encryptionKey %}
{% set elasticsearch_serviceAccountToken = salt['vault'].read_secret('kv/elk').elasticsearch_serviceAccountToken %}

install_kibana:
  pkg.installed:
    - name: kibana

kibana_config:
  file.managed:
    - name: /etc/kibana/kibana.yml
    - source: salt://role/elk/files/kibana.yml
    - mode: 660
    - user: root
    - group: kibana
    - template: jinja
    - context:
        xpack_encryptedSavedObjects_encryptionKey: {{ xpack_encryptedSavedObjects_encryptionKey }}
        xpack_reporting_encryptionKey: {{ xpack_reporting_encryptionKey }}
        xpack_security_encryptionKey: {{ xpack_security_encryptionKey }}
        elasticsearch_serviceAccountToken: {{ elasticsearch_serviceAccountToken }}

service_kibana:
  service.running:
    - name: kibana
    - enable: True
    - require:
      - pkg: install_kibana
    - watch:
      - file: kibana_config
