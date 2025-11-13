include:
  - base.openssl

easypki_repo:
  git.latest:
    - name: https://github.com/khaddict/easypki.git
    - target: /root/easypki
    - branch: main
    - rev: main
    - depth: 1
