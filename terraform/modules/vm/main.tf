resource "proxmox_virtual_environment_vm" "this" {
  name        = var.vm_name
  description = "Managed by Terraform"
  tags        = var.tags

  node_name = var.proxmox_host
  vm_id     = var.vm_id

  clone {
    vm_id   = var.clone_id
    full    = false

    retries = 3
  }

  timeout_clone = 60
  timeout_reboot = 60
  timeout_start_vm = 60
  timeout_shutdown_vm = 60

  agent {
    enabled = true
  }

  stop_on_destroy = true

  network_device {
    bridge   = "labvnet"
    firewall = true
  }

  operating_system {
    type = "l26"
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.vm_ip
        gateway = "10.10.10.1"
      }
    }

    user_account {
      username = "antlab"
      password = random_password.ubuntu_vm_password.result
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }    
}

resource "random_password" "ubuntu_vm_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

data "local_file" "ssh_public_key" {
  filename = "../ssh/proxmox_id_rsa.pub"
}

resource "local_file" "password_file" {
  content  = random_password.ubuntu_vm_password.result
  filename = "vm_password_${var.vm_name}.txt"
  file_permission = "0600"
}