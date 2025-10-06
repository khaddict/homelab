include:
  - base.python313_venv

/opt/assets_cli:
  file.directory:
    - mode: 755

/opt/assets_gui:
  file.directory:
    - mode: 755

assets_cli_repo:
  git.latest:
    - name: https://github.com/khaddict/assets_cli.git
    - target: /opt/assets_cli
    - branch: main
    - rev: main
    - depth: 1
    - require:
      - file: /opt/assets_cli
