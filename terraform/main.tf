# Network Setup

# resource "null_resource" "network_setup" {
#   connection {
#     type        = "ssh"
#     host        = var.proxmox_host_ip   # Replace with your hypervisor's IP
#     user        = "root"        # The username for SSH access
#     private_key = file("~/.ssh/ant_net") # Use your SSH private key
#   }

#   provisioner "file" {
#     source      = "../scripts/network_setup.sh"  # Path to the script on your local machine
#     destination = "/tmp/network_setup.sh"         # Path on the Proxmox hypervisor
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/network_setup.sh",  # Make the script executable
#       "bash /tmp/network_setup.sh"        # Execute the script
#     ]
#   }
# }

# Template Module

# module "vm_template" {
#   source = "./modules/vm-template"
#   proxmox_host = var.proxmox_host
#   proxmox_host_ip = "10.79.5.250"
# }

# VM Modules

module "vpn_gateway" {
  # depends_on = [ module.vm_template ]
  source = "./modules/vm"
  vm_name = "VPN-gateway"
  vm_id = 110
  clone_id = 9000
  vm_ip = "10.10.10.10/24"
  proxmox_host = var.proxmox_host
  config_script = "../scripts/vm_configuration/vpn_gateway.sh"
  tags = ["terraform", "networking"]
}

# resource "null_resource" "add_pcie_nic" {
#   depends_on = [ module.vpn_gateway ]
#   connection {
#     type        = "ssh"
#     host        = var.proxmox_host_ip   # Replace with your hypervisor's IP
#     user        = "root"        # The username for SSH access
#     private_key = file("~/.ssh/ant_net") # Use your SSH private key
#   }
#   # After VM is created, run the startup and wait for it
#   provisioner "remote-exec" {
#     inline = [
#       "qm set 110 -hostpci0 0000:04:00.0",
#       "qm guest exec 110 -- bash -c \"echo -e 'network:\\n  version: 2\\n  renderer: networkd\\n  ethernets:\\n    ens16:\\n      dhcp4: true' | sudo tee /etc/netplan/99_config.yaml && sudo netplan apply\"",
#       "qm stop 110",
#       "qm start 110"
#     ]
#   }
# }

# module "mqtt_broker" {
#   depends_on = [ module.vm_template ]
#   source = "./modules/vm"
#   vm_name = "MQTT-broker"
#   vm_id = 111
#   clone_id = 9000
#   vm_ip = "10.10.10.11/24"
#   proxmox_host = var.proxmox_host
#   config_script = "../scripts/vm_configuration/mqtt_broker.yaml"
#   tags = ["terraform", "server"]
# }

# resource "null_resource" "install_emqx" {
#   depends_on = [ module.mqtt_broker ]
#   connection {
#     type        = "ssh"
#     host        = var.proxmox_host_ip   # Replace with your hypervisor's IP
#     user        = "root"        # The username for SSH access
#     private_key = file("~/.ssh/ant_net") # Use your SSH private key
#   }
#   # After VM is created, run the startup and wait for it
#   provisioner "remote-exec" {
#     inline = [
#       "qm guest exec 111 -- bash -c \"curl -s https://assets.emqx.com/scripts/install-emqx-deb.sh | sudo bash && sudo apt-get install emqx && sudo systemctl start emqx && sudo systemctl enable emqx\"",
#       "qm stop 110",
#       "qm start 110"
#     ]
#   }
# }

# module "coap_server" {
#   depends_on = [ null_resource.convert_to_template ]
#   source = "./modules/vm"
#   vm_name = "CoAP-server"
#   vm_id = 112
#   clone_id = 9000
#   vm_ip = "10.10.10.12/24"
#   proxmox_host = var.proxmox_host
#   config_script = "../scripts/vm_configuration/coap_server.yaml"
#   tags = ["terraform", "server"]
# }

# module "file_server" {
#   depends_on = [ null_resource.convert_to_template ]
#   source = "./modules/vm"
#   vm_name = "File-server"
#   vm_id = 113
#   clone_id = 9000
#   vm_ip = "10.10.10.13/24"
#   proxmox_host = var.proxmox_host
#   config_script = "../scripts/vm_configuration/file_server.yaml"
#   tags = ["terraform", "server"]
# }

# Network Aliases

# module "firewall_alias_wildcard" {
#   source = "./modules/firewall_aliases"
#   alias_name = "wildcard"
#   alias_cidr = "0.0.0.0/0"
#   alias_comment = "Wildcard"
# }

# module "firewall_alias_gateway" {
#   source = "./modules/firewall_aliases"
#   alias_name = "gateway"
#   alias_cidr = "10.10.10.1"
#   alias_comment = "Gateway"
# }

# module "firewall_alias_labvnet" {
#   source = "./modules/firewall_aliases"
#   alias_name = "labvnet"
#   alias_cidr = "10.10.10.0/24"
#   alias_comment = "Lab Virtual Network"
# }

# # Firewall Modules

# module "lab_net_firewall" {
#   source = "./modules/firewall"
#   security_group_name = "labvnet"
#   comment = "Laboratory Network Segment"
# }

# Firewall options

# module "vpn_firewall_options" {
#   source = "./modules/firewall_options"
#   proxmox_host = var.proxmox_host
#   vm_id = 110
#   security_group_name = "vpn-firewall"
#   comment = "VPN Gateway Firewall Options"
#   depends_on = [ module.vpn_gateway, module.lab_net_firewall ]
# }

# module "mqtt_firewall_options" {
#   source = "./modules/firewall_options"
#   proxmox_host = var.proxmox_host
#   vm_id = 111
#   security_group_name = "labvnet"
#   comment = "MQTT Broker Firewall Options"
#   depends_on = [ module.mqtt_broker, module.lab_net_firewall ]
# }

# module "coap_firewall_options" {
#   source = "./modules/firewall_options"
#   proxmox_host = var.proxmox_host
#   vm_id = 112
#   security_group_name = "labvnet"
#   comment = "CoAP Broker Firewall Options"
#   depends_on = [ module.coap_server, module.lab_net_firewall ]
# }

# module "file_firewall_options" {
#   source = "./modules/firewall_options"
#   proxmox_host = var.proxmox_host
#   vm_id = 113
#   security_group_name = "labvnet"
#   comment = "File Server Firewall Options"
#   depends_on = [ module.file_server, module.lab_net_firewall ]
# }
