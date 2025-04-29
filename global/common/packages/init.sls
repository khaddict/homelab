{% import_yaml 'data/packages.yaml' as pkgs %}

include:
  - global.common.sources

common_packages:
  pkg.installed:
    - pkgs: {{ pkgs.common_packages }}
    - require:
      - file: /etc/apt/sources.list.d/homelab_aptly.list
      - file: /etc/apt/sources.list

purged_packages:
  pkg.purged:
    - pkgs: {{ pkgs.purged_packages }}
