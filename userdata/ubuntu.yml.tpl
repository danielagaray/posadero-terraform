#cloud-config
system_info:
  default_user:
    name: ubuntu

# Install basic apt packages so everything else works.
packages:
  - mysql-server

runcmd:
  - "echo installed"
