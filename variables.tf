variable "vsphere_server" {
  type = string
}

variable "vsphere_user" {
  type = string
}

variable "vsphere_password" {
  type = string
}

variable "datacenter_name" {
  type        = string
  description = "The name of the vSphere Datacenter into which resources will be created."
}

variable "cluster_name" {
  type        = string
  description = "The vSphere Cluster into which resources will be created."
}

variable "datastore_name" {
  type        = string
  description = "The vSphere Datastore into which resources will be created."
}

variable "vm_network_name" {
  type = string
}

variable "template_name" {
  type = string
}

variable "nameservers" {
  type    = list(any)
  default = []
}

variable "vsphere_folder" {
  type = string
}

variable "common_prefix" {
  type    = string
  default = "aiops"
}

variable "base_domain" {
  type    = string
  default = "gym.lan"
}

variable "accept_license" {
  type    = bool
  default = false
}
