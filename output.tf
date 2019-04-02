output "gitlab" {
  value = "${openstack_compute_instance_v2.gitlab.access_ip_v4}"
}

output "runners" {
  value =  "${join(", ", openstack_compute_instance_v2.runner.*.access_ip_v4)}"
}

