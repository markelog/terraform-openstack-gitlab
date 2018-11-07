resource "openstack_compute_keypair_v2" "ssh" {
  name       = "${var.key_name}"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}
