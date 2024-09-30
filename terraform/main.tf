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
#   name    = "gateway"
#   cidr    = "10.79.5.254"
#   comment = "Gateway IP"
# }

# resource "proxmox_virtual_environment_firewall_alias" "wildcard" {
#   name    = "wildcard"
#   cidr    = "0.0.0.0/0"
#   comment = "Wildcard CIDR"
# }

# resource "proxmox_virtual_environment_firewall_alias" "lab-net" {
#   name    = "lab-net"
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

resource "proxmox_virtual_environment_vm" "vpn-gateway" {
  name        = "VPN-gateway"
  description = "Managed by Terraform"
  tags        = ["terraform", "networking"]

  node_name = var.proxmox_host
  vm_id     = 100

   clone {
    vm_id = 102
  }

  agent {
    # Read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }
  
  # If agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

  # Network device configuration
  network_device {
    bridge = "lab1"
    firewall = true
  }

  # Public facing network port
    network_device {
    bridge = "vmbr1"
    firewall = true

  }

  # Operating system settings
  operating_system {
    type = "l26"  # Linux (2.6 or later)
  }

  # TPM state configuration
  tpm_state {
    version = "v2.0"
  }

  # Initialization block for cloud-init
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  serial_device {}
}

resource "proxmox_virtual_environment_vm" "MQTT-broker" {
  name        = "MQTT-broker"
  description = "Managed by Terraform"
  tags        = ["terraform", "server"]

  node_name = var.proxmox_host
  vm_id     = 101

   clone {
    vm_id = 102
  }

  agent {
    # Read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }
  
  # If agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

  # Network device configuration
  network_device {
    bridge = "lab1"
    firewall = true
  }

  # Operating system settings
  operating_system {
    type = "l26"  # Linux (2.6 or later)
  }

  # TPM state configuration
  tpm_state {
    version = "v2.0"
  }

  # Initialization block for cloud-init
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  serial_device {}
}

resource "proxmox_virtual_environment_vm" "CoAP-server" {
  name        = "CoAP-server"
  description = "Managed by Terraform"
  tags        = ["terraform", "server"]

  node_name = var.proxmox_host
  vm_id     = 103

   clone {
    vm_id = 102
  }

  agent {
    # Read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }
  
  # If agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

  # Network device configuration
  network_device {
    bridge = "lab1"
    firewall = true
  }

  # Operating system settings
  operating_system {
    type = "l26"  # Linux (2.6 or later)
  }

  # TPM state configuration
  tpm_state {
    version = "v2.0"
  }

  # Initialization block for cloud-init
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  serial_device {}
}

resource "proxmox_virtual_environment_vm" "File-server" {
  name        = "File-server"
  description = "Managed by Terraform"
  tags        = ["terraform", "server"]

  node_name = var.proxmox_host
  vm_id     = 104

   clone {
    vm_id = 102
  }

  agent {
    # Read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }
  
  # If agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

  # Network device configuration
  network_device {
    bridge = "lab1"
    firewall = true
  }

  # Operating system settings
  operating_system {
    type = "l26"  # Linux (2.6 or later)
  }

  # TPM state configuration
  tpm_state {
    version = "v2.0"
  }

  # Initialization block for cloud-init
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  serial_device {}
}

resource "proxmox_virtual_environment_firewall_rules" "VPN-Security-Group" {
  depends_on = [
    proxmox_virtual_environment_vm.vpn-gateway,
    proxmox_virtual_environment_cluster_firewall_security_group.lab-net,
  ]

  node_name = var.proxmox_host
  vm_id     = proxmox_virtual_environment_vm.vpn-gateway.vm_id

  # rule {
  #   type = "in"
  #   action = "ACCEPT"
  #   comment = "Allow VPN traffic IN"
  #   dest = "10.10.10.2"
  #   dport = "443"
  #   proto = "tcp"
  #   log = "info"
  # }

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.lab-net.name
    comment        = "Laboratory Network Segment"
    iface          = "net0"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "MQTT-Security-Group" {
  depends_on = [
    proxmox_virtual_environment_vm.MQTT-broker,
    proxmox_virtual_environment_cluster_firewall_security_group.lab-net,
  ]

  node_name = var.proxmox_host
  vm_id     = proxmox_virtual_environment_vm.MQTT-broker.vm_id


  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.lab-net.name
    comment        = "Laboratory Network Segment"
    iface          = "net0"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "CoAP-Security-Group" {
  depends_on = [
    proxmox_virtual_environment_vm.CoAP-server,
    proxmox_virtual_environment_cluster_firewall_security_group.lab-net,
  ]

  node_name = var.proxmox_host
  vm_id     = proxmox_virtual_environment_vm.CoAP-server.vm_id


  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.lab-net.name
    comment        = "Laboratory Network Segment"
    iface          = "net0"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "File-Security-Group" {
  depends_on = [
    proxmox_virtual_environment_vm.File-server,
    proxmox_virtual_environment_cluster_firewall_security_group.lab-net,
  ]

  node_name = var.proxmox_host
  vm_id     = proxmox_virtual_environment_vm.File-server.vm_id


  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.lab-net.name
    comment        = "Laboratory Network Segment"
    iface          = "net0"
  }
}

resource "proxmox_virtual_environment_firewall_options" "VPN-Firewall-Options" {
  depends_on = [proxmox_virtual_environment_vm.vpn-gateway]

  node_name = proxmox_virtual_environment_vm.vpn-gateway.node_name
  vm_id     = proxmox_virtual_environment_vm.vpn-gateway.vm_id

  dhcp          = true
  enabled       = true
  ipfilter      = false
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = true
  ndp           = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"
  radv          = true
}

resource "proxmox_virtual_environment_firewall_options" "MQTT-Firewall-Options" {
  depends_on = [proxmox_virtual_environment_vm.MQTT-broker]

  node_name = proxmox_virtual_environment_vm.MQTT-broker.node_name
  vm_id     = proxmox_virtual_environment_vm.MQTT-broker.vm_id

  dhcp          = true
  enabled       = true
  ipfilter      = false
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = true
  ndp           = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"
  radv          = true
}

resource "proxmox_virtual_environment_firewall_options" "CoAP-Firewall-Options" {
  depends_on = [proxmox_virtual_environment_vm.CoAP-server]

  node_name = proxmox_virtual_environment_vm.CoAP-server.node_name
  vm_id     = proxmox_virtual_environment_vm.CoAP-server.vm_id

  dhcp          = true
  enabled       = true
  ipfilter      = false
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = true
  ndp           = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"
  radv          = true
}

resource "proxmox_virtual_environment_firewall_options" "File-Firewall-Options" {
  depends_on = [proxmox_virtual_environment_vm.File-server]

  node_name = proxmox_virtual_environment_vm.File-server.node_name
  vm_id     = proxmox_virtual_environment_vm.File-server.vm_id

  dhcp          = true
  enabled       = true
  ipfilter      = false
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = true
  ndp           = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"
  radv          = true
}