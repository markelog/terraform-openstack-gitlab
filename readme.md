# Set up GtiLab with terraform via OpenStack

## Use case

If you orchestrate your VMs via OpenStack and want to quickly set up and maintain GitLab and runners for it.

[Install terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) and then download the template –
```sh
$ git clone git@github.com:markelog/terraform-gitlab-openstack.git
$ cd terraform-gitlab-openstack
```

Prepere the template –

```sh
$ terraform init
```

Copy example config as config file for terraform –

```sh
$ copy terraform.example.tfvars terraform.tfvars
```

Modify the options to your liking.

Apply the template –

```sh
$ terraform apply
```

## Values
```terraform
#### OpenStack related values ####

# Address to OpenStack API
auth_url                = "https://ds.tinkoff.cloud:5000/v3"

# OpenStack User Domain Name (optional)
user_domain_name        = "killa-gorilla.com"

# Name of the tenant
tenant                  = "pf-dev"

# Tenant ID
tenant_id               = "6238a6acffbf4bfbbfa3c784c3609564"

# Name of the network
network                 = "EXT_pf_dev"

# OpenStack username
user_name               = "killa"

# OpenStack password
password                = "gorilla"

# Name of the openstack instance
ssh_username            = "killa"

# Name of the openstack instance (it's not going to be copied anywhere)
ssh_key_file            = "/Users/killa/.ssh/id_rsa"

#### GitLab ####

# Address of the host
gitlab_host             = "http://gitlab.killa-gorilla.com"

# Password for GitLab UI
ui_password           = "test"

# Flavor of the openstack VM
flavor                  = "w1.c8r16"

# Size of the runners volumes
volume_size             = 50

# Type of the runners volumes
volume_type             = "volumes-ceph-gold"

# Amount of runners
num_runners             = 10

# GitLab config
gitlab_config           = "./configs/gitlab.rb"

# Docker config on runners
docker_config           = "./configs/runner/daemon.json"

# S3 for shared cache on runners
s3_endpoint             = "https://s3.killa-gorilla.com"
s3_access_key           = "ASDASDAQWQF51ASD"
s3_secret_key           = "ASDA#Qqwdasd12!#@asdA@!SAD"
```

# Notes

1. Tested on Ubuntu Bionic Beaver
1. Uses docker executor on runners (see [configs](bootstrap) folder)
1. Includes cron job for docker auto-cleaning on runners
