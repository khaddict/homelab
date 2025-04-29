apt-transport-https:
  pkg.installed

/usr/share/keyrings/elasticsearch-keyring.gpg:
  file.managed:
    - source: salt://role/elk/files/elasticsearch-keyring.gpg
    - mode: 644
    - user: root
    - group: root

/etc/apt/sources.list.d/elastic-8.x.list:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main
    - file: /etc/apt/sources.list.d/elastic-8.x.list
    - require:
      - file: /usr/share/keyrings/elasticsearch-keyring.gpg

elasticsearch:
  pkg.installed

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://role/elk/files/elasticsearch.yml
    - mode: 660
    - user: root
    - group: elasticsearch

/etc/elasticsearch/jvm.options.d/jvm-heap.options:
  file.managed:
    - source: salt://role/elk/files/jvm-heap.options
    - mode: 644
    - user: root
    - group: elasticsearch

service_elasticsearch:
  service.running:
    - name: elasticsearch
    - enable: True
    - require:
      - pkg: elasticsearch
    - watch:
      - file: /etc/elasticsearch/elasticsearch.yml
      - file: /etc/elasticsearch/jvm.options.d/jvm-heap.options
