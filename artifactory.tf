locals {
  metadata = templatefile("${path.module}/cloudinit/metadata.yaml", {
    base_domain = "${var.base_domain}"
  })
}


resource "random_password" "artifactory_password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

data "cloudinit_config" "userdata" {
  gzip          = false
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloudinit/userdata.yaml", {
      base_domain = "${var.base_domain}"
      public_key  = tls_private_key.deployer.public_key_openssh
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/cloudinit/install.sh", {
      base_domain          = "${var.base_domain}"
      artifactory_password = random_password.artifactory_password.result
      accept_license       = var.accept_license ? true : false
    })
  }
}

resource "vsphere_virtual_machine" "artifactory" {

  name             = "artifactory"
  resource_pool_id = data.vsphere_compute_cluster.this.resource_pool_id
  datastore_id     = data.vsphere_datastore.this.id

  folder = var.vsphere_folder

  num_cpus  = 4
  memory    = 8192
  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  cdrom {
    client_device = true
  }

  network_interface {
    network_id = data.vsphere_network.this.id
  }

  wait_for_guest_net_timeout = 30

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  disk {
    label            = "disk1"
    size             = 250 # Size in GB
    unit_number      = 1
    eagerly_scrub    = false
    thin_provisioned = true
  }

  disk {
    label            = "disk2"
    size             = 25 # Size in GB
    unit_number      = 2
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "guestinfo.metadata"          = base64encode(local.metadata)
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = data.cloudinit_config.userdata.rendered
    "guestinfo.userdata.encoding" = "base64"
  }

  lifecycle {
    prevent_destroy = false
  }
}