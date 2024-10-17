terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.65.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.api_url
  api_token = var.api_token
  # username = var.username
  # password = var.password
  insecure  = true

  ssh {
    agent = true
    username = "root"
    private_key = file("../ssh/proxmox_id_rsa")
}
}