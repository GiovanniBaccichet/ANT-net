resource "proxmox_virtual_environment_vm" "this" {
  name        = "ubuntu-cloud-template"
  description = "Managed by Terraform"
  tags        = ["terraform", "template"]

  node_name = var.proxmox_host
  vm_id     = 9000

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }
  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

  cpu {
    cores = 4
    type  = "x86-64-v2-AES" # recommended for modern CPUs
  }

  memory {
    dedicated = 4096
    floating  = 4096 # set equal to dedicated to enable ballooning
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_24_noble_qcow2_img.id
    interface    = "scsi0"
    size         = 20
  }

  initialization {
    user_account {
      username = "antlab"
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
      #   password = "antlab"
      password = random_password.ubuntu_vm_password.result
    }
  }

  operating_system {
    type = "l26"
  }

  template = false

  serial_device {}
}

resource "proxmox_virtual_environment_download_file" "latest_ubuntu_24_noble_qcow2_img" {
  content_type        = "iso"
  datastore_id        = "local"
  node_name           = var.proxmox_host
  url                 = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  overwrite_unmanaged = true
}

resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

data "local_file" "ssh_public_key" {
  filename = "../ssh/proxmox_id_rsa.pub"
}
