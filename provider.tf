provider "openstack" {
  user_name         = "${var.user_name}"
  password          = "${var.password}"
  tenant_name       = "${var.tenant}"
  tenant_id         = "${var.tenant_id}"
  auth_url          = "${var.auth_url}"
  region            = "${var.region}"
  user_domain_name  = "${var.user_domain_name}"

  insecure          = true
}
