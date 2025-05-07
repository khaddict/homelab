{% set elastic_password = salt['vault'].read_secret('kv/elk').elastic_password %}
{% import_json 'data/main.json' as data %}
{% set proxmox_nodes = data.proxmox_nodes.keys() | list %}
{% set proxmox_vms = data.proxmox_vms | map(attribute='vm_name') | list %}
{% set host_list = proxmox_nodes + proxmox_vms %}
{% set first_host = host_list[0].split('.')[0] %}
{% set other_hosts = host_list[1:] %}

logstash:
  pkg.installed

/etc/logstash/conf.d:
  file.recurse:
    - source: salt://role/elk/files/logstash_conf
    - include_empty: True
    - template: jinja
    - context:
        elastic_password: {{ elastic_password }}
        first_host: {{ first_host }}
        other_hosts: {{ other_hosts }}

/etc/logstash/pipelines.yml:
  file.managed:
    - source: salt://role/elk/files/pipelines.yml
    - mode: 644
    - user: root
    - group: root

/etc/logstash/jvm.options:
  file.managed:
    - source: salt://role/elk/files/jvm_logstash.options
    - mode: 644
    - user: root
    - group: root

service_logstash:
  service.running:
    - name: logstash
    - enable: True
    - require:
      - pkg: logstash
    - watch:
      - file: /etc/logstash/conf.d
      - file: /etc/logstash/pipelines.yml
      - file: /etc/logstash/jvm.options
