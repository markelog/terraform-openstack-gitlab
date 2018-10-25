output "GitLab" {
  value = "http://${openstack_compute_instance_v2.gitlab.name}.${var.tenant}.${var.domain}"
}

output "Root password" {
  value = "${var.root_password}"
}

output "GitLab SSH" {
  value = "${var.ssh_username}@${openstack_compute_instance_v2.gitlab.name}.${var.tenant}.${var.domain}"
}

output "GitLab runners" {
  value = "${var.num_runners}"
}

