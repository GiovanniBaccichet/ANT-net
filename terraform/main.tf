# VM Modules

module "vpn_gateway" {
  source = "./modules/vm"
  vm_name = "VPN-gateway"
  vm_id = 110
  vm_ip = "10.10.10.10"
  clone_id = 999
  proxmox_host = var.proxmox_host
  tags = ["terraform", "networking"]
}

module "mqtt_broker" {
  source = "./modules/vm"
  vm_name = "MQTT-broker"
  vm_id = 111
  vm_ip = "10.10.10.11"
  clone_id = 999
  proxmox_host = var.proxmox_host
  tags = ["terraform", "server"]
}

module "coap_server" {
  source = "./modules/vm"
  vm_name = "CoAP-server"
  vm_id = 112
  vm_ip = "10.10.10.12"
  clone_id = 999
  proxmox_host = var.proxmox_host
  tags = ["terraform", "server"]
}

module "file_server" {
  source = "./modules/vm"
  vm_name = "File-server"
  vm_id = 113
  vm_ip = "10.10.10.13"
  clone_id = 999
  proxmox_host = var.proxmox_host
  tags = ["terraform", "server"]
}

# Network Aliases

module "firewall_alias_wildcard" {
  source = "./modules/firewall_aliases"
  alias_name = "wildcard"
  alias_cidr = "0.0.0.0/0"
  alias_comment = "Wildcard"
}

module "firewall_alias_gateway" {
  source = "./modules/firewall_aliases"
  alias_name = "gateway"
  alias_cidr = "10.10.10.1"
  alias_comment = "Gateway"
}

module "firewall_alias_labvnet" {
  source = "./modules/firewall_aliases"
  alias_name = "labvnet"
  alias_cidr = "10.10.10.0/24"
  alias_comment = "Lab Virtual Network"
}

# Firewall Modules

module "lab_net_firewall" {
  source = "./modules/firewall"
  security_group_name = "labvnet"
  comment = "Laboratory Network Segment"
}

# Firewall options

# module "vpn_firewall_options" {
#   source = "./modules/firewall_options"
#   proxmox_host = var.proxmox_host
#   vm_id = 110
#   security_group_name = "vpn-firewall"
#   comment = "VPN Gateway Firewall Options"
#   depends_on = [ module.vpn_gateway ]
# }

module "mqtt_firewall_options" {
  source = "./modules/firewall_options"
  proxmox_host = var.proxmox_host
  vm_id = 111
  security_group_name = "labvnet"
  comment = "MQTT Broker Firewall Options"
  depends_on = [ module.coap_server, module.lab_net_firewall ]
}

module "coap_firewall_options" {
  source = "./modules/firewall_options"
  proxmox_host = var.proxmox_host
  vm_id = 112
  security_group_name = "labvnet"
  comment = "CoAP Broker Firewall Options"
  depends_on = [ module.mqtt_broker, module.lab_net_firewall ]
}

module "file_firewall_options" {
  source = "./modules/firewall_options"
  proxmox_host = var.proxmox_host
  vm_id = 113
  security_group_name = "labvnet"
  comment = "File Server Firewall Options"
  depends_on = [ module.file_server, module.lab_net_firewall ]
}
