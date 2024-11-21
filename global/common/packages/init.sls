{% import_yaml 'data/packages.yaml' as pkgs %}

include:
  - global.common.sources

common_packages:
  pkg.installed:
    - pkgs: {{ pkgs.common_packages }}
    - require:
      - file: homelab_aptly_config
      - file: sources_config

purged_packages:
  pkg.purged:
    - pkgs: {{ pkgs.purged_packages }}
