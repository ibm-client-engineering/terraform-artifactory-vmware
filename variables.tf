variable "rhsm_username" {
  type        = string
  description = "The username for your Red Hat Subscription Management account."
}

variable "rhsm_password" {
  type        = string
  description = "The password for your Red Hat Subscription Management account."
}

// vSphere Credentials

variable "vsphere_hostname" {
  type        = string
  description = "The fully qualified domain name or IP address of the vCenter Server instance."
}

variable "vsphere_username" {
  type        = string
  description = "The username to login to the vCenter Server instance."
  sensitive   = true
}

variable "vsphere_password" {
  type        = string
  description = "The password for the login to the vCenter Server instance."
  sensitive   = true
}

variable "vsphere_datacenter" {
  type        = string
  description = "The name of the vSphere Datacenter into which resources will be created."
}

variable "vsphere_cluster" {
  type        = string
  description = "The vSphere Cluster into which resources will be created."
}

variable "vsphere_datastore" {
  type        = string
  description = "The vSphere Datastore into which resources will be created."
}

variable "vsphere_network" {
  type        = string
  description = "The name of the target vSphere network segment."
}

variable "template_name" {
  type = string
}

variable "nameservers" {
  type    = list(any)
  default = []
}

variable "vsphere_folder" {
  type        = string
  description = "The name of the target vSphere folder."
}

variable "vsphere_resource_pool" {
  type        = string
  description = "The name of the target vSphere resource pool."
}

variable "common_prefix" {
  type        = string
  default     = ""
  description = "This value will be prepended to all names and hostnames."
}

variable "subnet_cidr" {
  type        = string
  default     = "192.168.252.0/24"
  description = "Subnet CIDR for the deployment."
}

variable "artifactory_ip" {
  type        = string
  default     = "192.168.252.9"
  description = "STatic IP address for the artifactory server."
}

variable "base_domain" {
  type    = string
  default = "gym.lan"
}

variable "accept_license" {
  type    = bool
  default = false
}