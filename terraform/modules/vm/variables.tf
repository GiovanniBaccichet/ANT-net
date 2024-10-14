variable "vm_name" {
  description = "The name of the VM"
}

variable "vm_id" {
  description = "The ID of the VM"
}

variable "vm_ip" {
  description = "Local IP address of the VM"
}

variable "clone_id" {
  description = "The ID of the base VM to clone"
}

variable "tags" {
  description = "Tags for the VM"
}

variable "proxmox_host" {
  description = "Proxmox host name"
}
