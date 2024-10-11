resource "proxmox_virtual_environment_firewall_rules" "this" {

  node_name = var.proxmox_host
  vm_id     = var.vm_id


  rule {
    security_group = var.security_group_name
    comment        = var.comment
    iface          = "net0"
  }
}

resource "proxmox_virtual_environment_firewall_options" "this" {

  node_name = var.proxmox_host
  vm_id     = var.vm_id

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
