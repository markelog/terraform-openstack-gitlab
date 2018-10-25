#!/bin/bash
set -eu

export DEBIAN_FRONTEND=noninteractive
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# Deal with locales
chmod 777 /etc/locale.gen
echo en_US.UTF-8 UTF-8 > /etc/locale.gen
locale-gen en_US.UTF-8
chmod 644 /etc/locale.gen

# Update packages
apt update -y
apt upgrade -y

# Install gitlab
apt-get install -y curl
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash
apt-get install -y gitlab-ce

# Apply configuration files
mkdir -p /etc/gitlab
cat /tmp/gitlab.rb.append >> /tmp/gitlab.rb
mv --force /tmp/gitlab.rb /etc/gitlab/gitlab.rb
chmod 0600 /etc/gitlab/gitlab.rb
chown root:root /etc/gitlab/gitlab.rb

/opt/gitlab/bin/gitlab-ctl reconfigure
