resource "proxmox_virtual_environment_cluster_firewall_security_group" "this" {
  name    = var.security_group_name
  comment = var.comment

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow local traffic"
    dest    = var.security_group_name
    log     = "info"
  }

  rule {
    type    = "out"
    action  = "ACCEPT"
    comment = "Allow local traffic"
    dest    = var.security_group_name
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
