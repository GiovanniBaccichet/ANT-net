# VM Modules

module "vpn_gateway" {
  source = "./modules/vm"
  vm_name = "VPN-gateway"
  vm_id = 110
  clone_id = 999
  proxmox_host = var.proxmox_host
  tags = ["terraform", "networking"]
}

# module "mqtt_broker" {
#   source = "./modules/vm"
#   vm_name = "MQTT-broker"
#   vm_id = 111
#   clone_id = 102
#   proxmox_host = var.proxmox_host
#   tags = ["terraform", "server"]
# }

# module "coap_server" {
#   source = "./modules/vm"
#   vm_name = "CoAP-server"
#   vm_id = 113
#   clone_id = 102
#   proxmox_host = var.proxmox_host
#   tags = ["terraform", "server"]
# }

# module "file_server" {
#   source = "./modules/vm"
#   vm_name = "File-server"
#   vm_id = 114
#   clone_id = 102
#   proxmox_host = var.proxmox_host
#   tags = ["terraform", "server"]
# }

# Firewall Modules

# module "lab_net_firewall" {
#   source = "./modules/firewall"
#   security_group_name = "lab-net"
#   comment = "Laboratory Network Segment"
# }


# module "vpn_firewall_options" {
#   source = "./modules/firewall"
#   security_group_name = "vpn-firewall"
#   comment = "VPN Gateway Firewall Options"
# }

# module "mqtt_firewall_options" {
#   source = "./modules/firewall"
#   security_group_name = "mqtt-firewall"
#   comment = "MQTT Broker Firewall Options"
# }

# module "coap_firewall_options" {
#   source = "./modules/firewall"
#   security_group_name = "coap-firewall"
#   comment = "CoAP Server Firewall Options"
# }

# module "file_firewall_options" {
#   source = "./modules/firewall"
#   security_group_name = "file-firewall"
#   comment = "File Server Firewall Options"
# }
