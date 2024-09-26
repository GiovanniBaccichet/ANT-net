terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.65.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.api_url
  api_token = var.api_token
  insecure = true
}

# resource "proxmox_virtual_environment_firewall_alias" "gateway" {
#   name    = "gateway2"
#   cidr    = "10.79.5.254"
#   comment = "Gateway IP"
# }

# resource "proxmox_virtual_environment_firewall_alias" "wildcard" {
#   name    = "wildcard2"
#   cidr    = "0.0.0.0/0"
#   comment = "Wildcard CIDR"
# }

# resource "proxmox_virtual_environment_firewall_alias" "lab-net" {
#   name    = "lab-net2"
#   cidr    = "10.10.10.0/24"
#   comment = "Lab Network"
# }

resource "proxmox_virtual_environment_cluster_firewall_security_group" "lab-net" {
  name    = "lab-net-test"
  comment = "Laboratory Network Segment"

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow local traffic"
    dest    = "lab-net"
    log     = "info"
  }

  rule {
    type    = "out"
    action  = "ACCEPT"
    comment = "Allow local traffic"
    dest    = "lab-net"
    log     = "info"
  }

  rule {
    type    = "out"
    action  = "ACCEPT"
    comment = "Allow traffic to the gateway"
    dest    = "gateway"
    log     = "info"
  }

  rule {
    type    = "out"
    action  = "DROP"
    comment = "Default deny all outbound traffic"
    dest    = "wildcard"
    log     = "info"
  }
  
}

# resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
#   name        = "VM1"
#   description = "Managed by Terraform"
#   tags        = ["terraform", "ubuntu"]

#   node_name = var.proxmox_host
#   # vm_id     = 4321

#    clone {
#     vm_id = 102
#   }

#   agent {
#     # Read 'Qemu guest agent' section, change to true only when ready
#     enabled = false
#   }
  
#   # If agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
#   stop_on_destroy = true

#   # Network device configuration
#   network_device {
#     bridge = "lab1"
#     firewall = true
#   }

#   # Operating system settings
#   operating_system {
#     type = "l26"  # Linux (2.6 or later)
#   }

#   # TPM state configuration
#   tpm_state {
#     version = "v2.0"
#   }

#   # Initialization block for cloud-init
#   initialization {
#     ip_config {
#       ipv4 {
#         address = "dhcp"
#       }
#     }
#   }

#   serial_device {}
# }

resource "proxmox_virtual_environment_firewall_rules" "inbound" {
  depends_on = [
    # proxmox_virtual_environment_vm.example,
    proxmox_virtual_environment_cluster_firewall_security_group.lab-net,
  ]

  node_name = var.proxmox_host
  vm_id     = 109


  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.lab-net.name
    comment        = "Laboratory Network Segment"
    iface          = "net0"
  }
}