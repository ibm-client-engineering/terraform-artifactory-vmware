// Base domain from which the cluster domain is a subdomain.
base_domain = "gym.lan"

// Name of the vSphere server. The dev cluster is on "vcsa.vmware.devcluster.openshift.com".
vsphere_server = "ocpgym-vc.techzone.ibm.local"

// User on the vSphere server.
vsphere_user = "gymuser-pse232k8@techzone.ibm.local"

// Password of the user on the vSphere server.
vsphere_password = "MDGabhNK"

// Name of the vSphere cluster. The dev cluster is "devel".
cluster_name = "ocp-gym"

// Name of the vSphere data center. The dev cluster is "dc1".
datacenter_name = "IBMCloud"

// Name of the vSphere data store to use for the VMs. The dev cluster uses "nvme-ds1".
datastore_name = "gym-0600010stv-pse232k8-storage"

// Name of the RHCOS VM template to clone to create VMs for the cluster
template_name = "ocp-gym/gym-0600010stv-pse232k8/linux-rhel95-template"

// Name of the VM Network for your cluster nodes
vm_network_name = "gym-0600010stv-pse232k8-segment"

vsphere_folder = "ocp-gym/gym-0600010stv-pse232k8"

accept_license = true