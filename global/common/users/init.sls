delete_debian_user:
  user.absent:
    - name: debian
    - purge: True

delete_ubuntu_user:
  user.absent:
    - name: ubuntu
    - purge: True
