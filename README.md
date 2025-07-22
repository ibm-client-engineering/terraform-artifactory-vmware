# Terraform Artifactory VMware Deployment

This repository provides Terraform configurations to deploy Artifactory on a VMware vSphere environment.

## Requirements

Before deploying, ensure you have:

*   [Terraform](https://www.terraform.io/) - Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services. Terraform codifies cloud APIs into declarative configuration files.
*   Access to a VMware vSphere environment with the proper authorization to create VMs.
*   DNS entry for `artifactory.gym.lan` pointing to the deployed VM's IP address (e.g., `192.168.252.8`).

---

## IBM TechZone Access to vSphere

If you are an IBMer or Business Parter, you can request access to vSphere through IBM TechZone.

[VMware on IBM Cloud Environments](https://techzone.ibm.com/collection/tech-zone-certified-base-images/journey-vmware-on-ibm-cloud-environments)

Select `Request vCenter access (OCP Gym)

---

## Pre flight checklist

### 🛠️ Preparing a RHEL 9 Template for Terraform on vSphere

To use this Terraform code to deploy virtual machines on vSphere, you first need a **VM template**. Here's how to create one using a RHEL 9 image.

---

#### 1. 🎯 Define the Goal

You want to deploy VMs using Terraform, but Terraform needs a **pre-existing VM template** to clone from.

---

#### 2. 🧱 Use the Red Hat Image Builder

Red Hat provides a tool to generate OVA files for RHEL 9. This is a convenient way to create a VM image that can be imported into vSphere.

> 🔗 You can find the [image builder](https://console.redhat.com/insights/image-builder/) on the Red Hat Customer Portal.

---

#### 3. 📦 Deploy the OVA to vSphere

Once you have the OVA file:

1. Open **vSphere Client**.
2. Go to **Deploy OVF Template**.
3. Upload the RHEL 9 OVA.
4. Follow the wizard to deploy it as a VM or template.

--- 

### Install Terraform

> 💡 **Tip:** If you're connecting to vSphere through a **WireGuard VPN**, you might experience **timeouts or connectivity issues**.  
> In such cases, consider running your Terraform commands from a **bastion host** that resides **within the same network or environment** as vSphere.  
> This can help avoid VPN-related latency or firewall restrictions that interfere with the connection.

To install **Terraform** from a **RHEL 8** bastion host, follow these steps:

---

#### ✅ Step-by-Step Installation Guide

##### 1. **Install Required Packages**
Open a terminal and run:

```bash
sudo dnf install -y yum-utils git bind-utils
```

##### 2. **Add the HashiCorp Repository**
Create a new repo file:

```bash
sudo tee /etc/yum.repos.d/hashicorp.repo <<EOF
[hashicorp]
name=HashiCorp Stable - RHEL 8
baseurl=https://rpm.releases.hashicorp.com/RHEL/8/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://rpm.releases.hashicorp.com/gpg
EOF
```

##### 3. **Install Terraform**
Now install Terraform:

```bash
sudo dnf install -y terraform
```

##### 4. **Verify Installation**
Check the installed version:

```bash
terraform -version
```
---

### Configure Networking

> 💡 **Important:** Currently this Terraform module assumes that the network is **192.168.252.0/24**.
> This is hard-coded into the module, sorry.

#### Required Static IPs

There are 4 static IP addresses that are needed.

| Hostname       | IP               | FQDN                  |
|----------------|------------------|-----------------------|
| `artifactory`  | `192.168.252.8`  | `haproxy.gym.lan`     |

The example table above assumes the `base_domain` is set to `gym.lan`

#### 🛠️ How to Set Static IPs in pfSense

1. **Log in to pfSense** via the web UI (usually at `https://192.168.252.1`).
2. Navigate to:  
   **Services** → **DNS Forwarder**.
3. Scroll down to **Host Overrides**.
4. For each device:
   - Click **Add**.
   - Set the **IP address** (from the table above).
   - Set the **Hostname** (e.g., `artifactory`).
   - Set the **Domain** to `gym.lan` (or appropriate base domain) to form the FQDN.
   - Click **Save**.
5. Click **Apply Changes** at the top of the page.

---

#### 🔁 Verifying DNS Resolution

To ensure the FQDNs resolve correctly:

- Test resolution using:

```bash
nslookup artifactory.gym.lan
```

#### 🧭 Enable DNS Forwarder Static Mapping Registration in pfSense

To ensure that your static DHCP mappings (like `artifactory.gym.lan`, etc.) are resolvable via DNS, you need to enable a specific setting in pfSense:

##### ✅ Steps

1. Log in to the **pfSense Web UI**.
2. Navigate to:  
   **Services** → **DNS Forwarder**.
3. Scroll down to the **General DNS Forwarder Options** section.
4. Check the box for: **Register DHCP static mappings in DNS forwarder**
5. Click **Save** and then **Apply Changes**.

> 💡 This setting controls whether hostnames assigned to static DHCP clients are automatically added to the DNS forwarder or resolver so they can be resolved locally.

### Clone the repository

Clone this repository to your local workstation. This will allow you to configure and run terraform.

#### 1. **Install Required Packages**
Open a terminal and run:

```bash
sudo dnf install -y git bind-utils
```

#### 2. **Clone the repo**
Now clone this repo:

```bash
git clone <repo>
```

### Define Terraform variables

There is a file called `terraform.tfvars.example`. Copy this file to `terraform.tfvars` and set variables here according to
your needs.

## Deploy

We are now ready to deploy our infrastructure. First we ask terraform to plan the execution with: 

```
terraform plan
```

now we can deploy our resources with:

```
terraform apply
```

## Accessing Artifactory

*   **Default Username**: `admin`
*   **Auto-generated Password**: To retrieve the password, run:
    ```bash
    terraform output -raw artifactory_password && echo
    ```
*   **Base URL**: `https://artifactory.gym.lan:8443`

## Troubleshooting

If you see the "Artifactory is starting up" page, it indicates the web server is running but there's an issue with the Artifactory application itself. Check the following:

*   Ensure the PostgreSQL database is running and accessible.
*   Verify that disk space is not at 100% utilization.

## Important Notes

*   The default daily/weekly backups are disabled during the first startup.

## Destroy

To destroy all resources, run the following command.

```
terraform destroy -auto-approve
```