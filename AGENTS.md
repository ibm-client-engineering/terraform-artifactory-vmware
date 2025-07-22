# AGENT GUIDELINES FOR terraform-artifactory-vmware

This repository manages Artifactory deployment on VMware using Terraform.

## Commands

*   **Initialize Terraform**: `terraform init`
*   **Validate Configuration**: `terraform validate`
*   **Plan Deployment**: `terraform plan`
*   **Apply Deployment**: `terraform apply`
*   **Destroy Deployment**: `terraform destroy`

## Code Style Guidelines

*   **Formatting**: Use `terraform fmt` to format `.tf` files.
*   **Naming Conventions**:
    *   Resources: `type_name` (e.g., `vsphere_virtual_machine.artifactory_vm`)
    *   Variables: `snake_case` (e.g., `vm_name`, `datacenter_name`)
    *   Outputs: `snake_case`
*   **Modularity**: Organize configurations into logical files (e.g., `main.tf`, `variables.tf`, `outputs.tf`).
*   **Comments**: Use comments to explain complex logic or non-obvious configurations.
*   **Error Handling**: Leverage Terraform's built-in validation and error messages.
*   **Providers**: Explicitly define provider versions.
*   **State Management**: Be mindful of Terraform state. Avoid manual modifications.
