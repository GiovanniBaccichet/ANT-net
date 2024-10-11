resource "proxmox_virtual_environment_vm" "this" {
  name        = var.vm_name
  description = "Managed by Terraform"
  tags        = var.tags

  node_name = var.proxmox_host
  vm_id     = var.vm_id

  clone {
    vm_id = var.clone_id
    full = false
    retries = 3
  }

  agent {
    enabled = true
  }

  stop_on_destroy = true

  network_device {
    bridge  = "labvnet"
    firewall = true
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}
