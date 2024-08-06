{% set root_hash = salt['vault'].read_secret('kv/system').root_hash %}

delete_debian_user:
  user.absent:
    - name: debian
    - purge: True

delete_ubuntu_user:
  user.absent:
    - name: ubuntu
    - purge: True

manage_root_user:
  user.present:
    - name: root
    - password: {{ root_hash }}
