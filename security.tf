resource "openstack_compute_secgroup_v2" "gitlab" {
  name        = "${var.prefix}gitlab"
  description = "Gitlab security group"
  region      = "${var.region}"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 23
    to_port     = 23
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  # For Prometheus exporters
  rule {
    from_port   = 9000
    to_port     = 9450
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "runner" {
  name        = "${var.prefix}runner"
  description = "Gitlab runner security group"
  region      = "${var.region}"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port = -1
    to_port = -1
    ip_protocol = "icmp"
    cidr = "0.0.0.0/0"
  }

  # For Prometheus exporters
  rule {
    from_port   = 9000
    to_port     = 9450
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}
