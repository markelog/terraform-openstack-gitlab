resource "random_id" "token" {
  byte_length = 15
}

locals {
  token = "${var.gitlab_token != "" ? var.gitlab_token : format("%s", random_id.token.hex)}"
  host  = "http://${openstack_compute_instance_v2.gitlab.name}.${var.tenant}.${var.domain}"
}

data "template_file" "gitlab" {
  template = "${file("${path.module}/templates/gitlab.rb.append")}"

  vars {
    root_password = "${var.root_password}"
    token = "${local.token}"
  }
}

resource "openstack_compute_instance_v2" "gitlab" {
  name            = "${var.prefix}gitlab"
  region          = "${var.region}"
  image_name      = "${var.image}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${openstack_compute_keypair_v2.ssh.name}"
  security_groups = ["${openstack_compute_secgroup_v2.gitlab.name}"]

  network {
    name = "${var.network}"
  }

  connection {
    host        = "${self.network.0.fixed_ip_v4}"
    user        = "${var.ssh_username}"
    private_key = "${file("${var.ssh_key_file}")}"
  }

  provisioner "file" {
    content     = "${data.template_file.gitlab.rendered}"
    destination = "/tmp/gitlab.rb.append"
  }

  provisioner "file" {
    source      = "${var.gitlab_config}"
    destination = "/tmp/gitlab.rb"
  }

  provisioner "file" {
    source      = "${path.module}/bootstrap/gitlab.sh"
    destination = "/tmp/gitlab.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/gitlab.sh",
      "sudo /tmp/gitlab.sh",
      "sudo rm -rf /tmp/gitlab.sh"
    ]
  }
}

resource "openstack_blockstorage_volume_v2" "runner" {
  name        = "${var.prefix}gitlab-${count.index+1}"
  description = "Gitlab runner volume"
  size        = "${var.volume_size}"
  count       = "${var.num_runners}"
  volume_type = "${var.volume_type}"
}

resource "openstack_compute_instance_v2" "runner" {
  name            = "${var.prefix}gitlab-runner-${count.index+1}"
  count           = "${var.num_runners}"
  region          = "${var.region}"
  image_name      = "${var.image}"
  flavor_name     = "${var.runner_flavor}"
  key_pair        = "${openstack_compute_keypair_v2.ssh.name}"
  security_groups = ["${openstack_compute_secgroup_v2.runner.name}"]

  network {
    name = "${var.network}"
  }

  connection {
    host        = "${self.network.0.fixed_ip_v4}"
    user        = "${var.ssh_username}"
    private_key = "${file("${var.ssh_key_file}")}"
  }

  provisioner "file" {
    source      = "${path.module}/bootstrap/runner/setup.sh"
    destination = "/tmp/gitlab-runner-setup.sh"
  }

  provisioner "file" {
    source      = "${path.module}/bootstrap/runner/cleaner.sh"
    destination = "/tmp/gitlab-runner-cleaner.sh"
  }

  provisioner "file" {
    source      = "${var.docker_config}"
    destination = "/tmp/daemon.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/gitlab-runner-cleaner.sh",
      "sudo chmod +x /tmp/gitlab-runner-setup.sh",

      "sudo mv /tmp/gitlab-runner-cleaner.sh /etc/cron.daily/",
      "sudo mkdir -p /etc/docker/",
      "sudo mv /tmp/daemon.json /etc/docker/",
    ]
  }

  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "sudo gitlab-runner unregister --name ${self.name}",
    ]
  }
}

resource "openstack_compute_volume_attach_v2" "runner" {
  count       = "${var.num_runners}"
  instance_id = "${element(openstack_compute_instance_v2.runner.*.id, count.index)}"
  volume_id   = "${element(openstack_blockstorage_volume_v2.runner.*.id, count.index)}"
}

resource "null_resource" "runner" {
  count       = "${var.num_runners}"
  depends_on  = ["openstack_compute_volume_attach_v2.runner"]

  provisioner "remote-exec" {
    connection {
      host        = "${element(openstack_compute_instance_v2.runner.*.access_ip_v4, count.index)}"
      user        = "${var.ssh_username}"
      private_key = "${file("${var.ssh_key_file}")}"
    }

    inline = [
      "sudo mkfs.ext4 -F /dev/sdb",
      "sudo mount /dev/sdb /mnt",

      "sudo /tmp/gitlab-runner-setup.sh ${var.prefix}gitlab-runner-${count.index+1} ${local.host} ${local.token} ${var.runner_image} ${var.ssh_username}"
    ]
  }
}
