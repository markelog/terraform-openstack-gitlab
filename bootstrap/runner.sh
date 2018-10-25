#!/bin/bash
set -eu

export DEBIAN_FRONTEND=noninteractive
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

runner_name=${1}
runner_host=${2}
runner_token=${3}
runner_image=${4}
user=${5}

apt update

## Install docker
apt install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ${user}

## Install GitLab Multi-Runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
apt-get install -y gitlab-runner

# See https://github.com/docker/libnetwork/issues/1654
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Configure runner
gitlab-runner register \
  --non-interactive \
  --url ${runner_host} \
  --registration-token ${runner_token} \
  --name ${runner_name} \
  --executor docker \
  --docker-image ${runner_image} 2>&1 >> /var/log/gitlab-runner.boostrap.log
