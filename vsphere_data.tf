# Retrieve information about the specified vSphere datacenter
data "vsphere_datacenter" "this" {
  name = var.datacenter_name
}

# Retrieve information about the compute cluster within the specified datacenter
data "vsphere_compute_cluster" "this" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.this.id
}

# Retrieve information about the datastore within the specified datacenter
data "vsphere_datastore" "this" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.this.id
}

# Retrieve information about the network within the specified datacenter
data "vsphere_network" "this" {
  name          = var.vm_network_name
  datacenter_id = data.vsphere_datacenter.this.id
}

# Retrieve information about the virtual machine template within the specified datacenter
data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.this.id
}
