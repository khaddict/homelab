{% import_yaml 'data/packages.yaml' as pkgs %}

common_packages:
  pkg.installed:
    - pkgs: {{ pkgs.common_packages }}

purged_packages:
  pkg.purged:
    - pkgs: {{ pkgs.purged_packages }}
