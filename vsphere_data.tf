# Retrieve information about the specified vSphere datacenter
data "vsphere_datacenter" "this" {
  name = var.vsphere_datacenter
}

# Retrieve information about the compute cluster within the specified datacenter
data "vsphere_compute_cluster" "this" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.this.id
}

# Retrieve information about the datastore within the specified datacenter
data "vsphere_datastore" "this" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.this.id
}

# Retrieve information about the network within the specified datacenter
data "vsphere_network" "this" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.this.id
}

# Retrieve information about the virtual machine template within the specified datacenter
data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.this.id
}

# get the resource pool ID using its full path
data "vsphere_resource_pool" "target_pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.this.id
}