# VM Modules

module "vpn_gateway" {
  source = "/modules/vm"
  vm_name = "VPN-gateway"
  vm_id = 110
  clone_id = 102
  tags = ["terraform", "networking"]
}

module "mqtt_broker" {
  source = "/modules/vm"
  vm_name = "MQTT-broker"
  vm_id = 111
  clone_id = 102
  tags = ["terraform", "server"]
}

module "coap_server" {
  source = "/modules/vm"
  vm_name = "CoAP-server"
  vm_id = 113
  clone_id = 102
  tags = ["terraform", "server"]
}

module "file_server" {
  source = "/modules/vm"
  vm_name = "File-server"
  vm_id = 114
  clone_id = 102
  tags = ["terraform", "server"]
}

# Firewall Modules

module "lab_net_firewall" {
  source = "./modules/firewall"
  security_group_name = "lab-net"
  comment = "Laboratory Network Segment"
}

module "vpn_firewall_options" {
  source = "/modules/firewall"
  node_name = module.vpn_gateway.node_name
  vm_id = module.vpn_gateway.vm_id
}

module "mqtt_firewall_options" {
  source = "/modules/firewall"
  node_name = module.mqtt_broker.node_name
  vm_id = module.mqtt_broker.vm_id
}

module "coap_firewall_options" {
  source = "/modules/firewall"
  node_name = module.coap_server.node_name
  vm_id = module.coap_server.vm_id
}

module "file_firewall_options" {
  source = "/modules/firewall"
  node_name = module.file_server.node_name
  vm_id = module.file_server.vm_id
}
