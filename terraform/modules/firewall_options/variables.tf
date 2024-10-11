variable "proxmox_host" {
  description = "Proxmox host name"
}

variable "vm_id" {
  description = "The VM ID of the virtual machine."
  type        = string
}

variable "security_group_name" {
  description = "The security group associated with the firewall rule."
  type        = string
}

variable "comment" {
  description = "Comment for the firewall rule."
  type        = string
  default     = "Firewall rule comment"
}
