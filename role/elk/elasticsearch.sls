elk_dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https

manage_elk_gpg:
  file.managed:
    - name: /usr/share/keyrings/elasticsearch-keyring.gpg
    - source: salt://role/elk/files/elasticsearch-keyring.gpg
    - mode: 644
    - user: root
    - group: root

elk_repo_pkg:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main
    - file: /etc/apt/sources.list.d/elastic-8.x.list
    - require:
      - file: manage_elk_gpg

install_elasticsearch:
  pkg.installed:
    - name: elasticsearch

elasticsearch_config:
  file.managed:
    - name: /etc/elasticsearch/elasticsearch.yml
    - source: salt://role/elk/files/elasticsearch.yml
    - mode: 660
    - user: root
    - group: elasticsearch

jvm_heap_options:
  file.managed:
    - name: /etc/elasticsearch/jvm.options.d/jvm-heap.options
    - source: salt://role/elk/files/jvm-heap.options
    - mode: 644
    - user: root
    - group: elasticsearch

service_elasticsearch:
  service.running:
    - name: elasticsearch
    - enable: True
    - require:
      - pkg: install_elasticsearch
    - watch:
      - file: elasticsearch_config
      - file: jvm_heap_options
