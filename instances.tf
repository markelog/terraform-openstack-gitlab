resource "random_id" "token" {
  byte_length = 15
}

locals {
  token = "VCmgGh5aTyzCckmeRsTL"
  host = "http://${openstack_compute_instance_v2.gitlab.name}.${var.tenant}.${var.domain}"
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
    source      = "${var.config_file}"
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
    source      = "${path.module}/bootstrap/runner.sh"
    destination = "/tmp/runner.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/runner.sh",
      "sudo /tmp/runner.sh ${self.name} ${local.host} ${local.token} ${var.runner_image} ${var.ssh_username}"
    ]
  }

  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "sudo gitlab-runner unregister --name ${self.name}"
    ]
  }
}

