resource "proxmox_virtual_environment_vm" "this" {
  name        = "ubuntu-cloud-template"
  description = "Managed by Terraform"
  tags        = ["terraform", "template"]

  node_name = var.proxmox_host
  vm_id     = 9000

  timeout_reboot = 60
  timeout_start_vm = 60
  timeout_shutdown_vm = 60

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
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
    # file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_24_noble_qcow2_img.id
    file_id = "local:iso/noble-server-cloudimg-amd64.img"
    interface    = "scsi0"
    size         = 20
  }

  initialization {
    user_account {
      username = "antlab"
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
      #   password = "antlab"
      # password = random_password.ubuntu_vm_password.result
      password = "antlab"
    }
  }

  operating_system {
    type = "l26"
  }

  template = false

  serial_device {}
}

# resource "proxmox_virtual_environment_download_file" "latest_ubuntu_24_noble_qcow2_img" {
#   content_type        = "iso"
#   datastore_id        = "local"
#   node_name           = var.proxmox_host
#   url                 = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
#   overwrite_unmanaged = true
# }

resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

data "local_file" "ssh_public_key" {
  filename = "../ssh/proxmox_id_rsa.pub"
}

resource "null_resource" "convert_to_template" {
  depends_on = [ proxmox_virtual_environment_vm.this ]
  connection {
    type        = "ssh"
    host        = var.proxmox_host_ip   # Replace with your hypervisor's IP
    user        = "root"        # The username for SSH access
    private_key = file("~/.ssh/ant_net") # Use your SSH private key
  }
  # After VM is created, run the startup and wait for it
  provisioner "remote-exec" {
    inline = [
      "sleep 60",
      "qm stop 9000",
      "sleep 30",
      "qm template 9000",
      "sleep 10"
    ]
  }
}