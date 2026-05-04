# OS Scripts

## Install bashly

apt - Ubuntu / Debian

```shell
sudo apt -y update
sudo apt -y install build-essential libyaml-dev ruby-dev
sudo gem install bashly
```

dnf - Fedora / CentOS / Red Hat

```shell
sudo dnf -y update
sudo dnf -y install @development-tools libyaml-devel ruby-devel
gem install bashly
```

```shell
bashly generate
```

## Reference

- https://bashly.dev
- https://github.com/gruntwork-io/bash-commons
- https://github.com/bitnami/containers/tree/main/bitnami/pgpool/4/debian-12
- https://github.com/ppo/bash-colors
- https://github.com/charmbracelet/gum
- https://github.com/kward/shflags
- https://github.com/kvz/bash3boilerplate
- https://github.com/webinstall/webi-installers