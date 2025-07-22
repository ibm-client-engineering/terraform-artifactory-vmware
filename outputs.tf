output "message" {
  value = "Artifactory can take a few minutes to start."
}

output "artifactory_url" {
  value = "https://artifactory.${var.base_domain}:8443/ui/login/"
}

output "artifactory_ip_address" {
  description = "The IP address of the artifactory virtual machine"
  value       = vsphere_virtual_machine.artifactory.default_ip_address
}

output "artifactory_password" {
  description = "Generated password for Artifactory admin user."
  value       = random_password.artifactory_password.result
  sensitive   = true
}