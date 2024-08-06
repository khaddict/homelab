install_prometheus_node_exporter:
  pkg.installed:
    - name: prometheus-node-exporter

service_prometheus_node_exporter:
  service.running:
    - name: prometheus-node-exporter
    - enable: True
