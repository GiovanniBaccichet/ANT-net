<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/GiovanniBaccichet/ANT-net">
    <img src="images/logo.png" alt="Logo" width="160">
  </a>

  <h3 align="center">ANT Net</h3>

  <p align="center">
    Infrastructure as Code (IaC) for Advanced Network Technologies (ANT) Educational Lab
    <br />
    <a href="https://antlab.deib.polimi.it/"><strong>ANT Lab Website »</strong></a>
    <br />
    <br />
  </p>
</div>



<!-- ABOUT THE PROJECT -->
## About The Project

ANT-Net is a self deployable virtual infrastructure that hosts different services that are used in different courses at Politecnico di Milano. In particular it hosts:
- **VPN Gateway**: <img src="https://github.com/walkxcode/dashboard-icons/blob/main/png/wireguard.png?raw=true" style="width:15px;"> [Wireguard](https://www.wireguard.com/) server w/ web interface for managing users and remote access to the infrastructure
- **MQTT Broker**: <img src="https://github.com/walkxcode/dashboard-icons/blob/main/png/emqx.png?raw=true" style="width:15px;"> [EMQX](https://www.emqx.com/en) server with web interface for managing topics and clients
- **CoAP Server**: Python-based CoAP server
- **File Server + Sensor Network**: a RPi network sending wireless data to a centralized file management service

The diagram below shows the logical organization of the virtual infrastructure, and in particular how the network is segmented to prevent users from communicating with machines on the outside of the virtual lab network.

![ANT-Net Infrastructure](images/proxmox-infra.png)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

The project is build around <img src="https://github.com/walkxcode/dashboard-icons/blob/main/png/proxmox.png?raw=true" style="width:15px;"> [Proxmox](https://www.proxmox.com/en/). The deployment of VMs is performed through <img src="https://www.terraform.io/img/logo.png" style="width:15px;"> [Hashicorp Terraform](https://www.terraform.io/), using the [Terraform Provider for Proxmox](https://github.com/bpg/terraform-provider-proxmox). Despite being very well documented, said provider lacks some features regarding Proxmox templating and networking, and for that reason I added the scripts in `scripts/`. Additionally, the VM configuration is performed with the scripts in `scripts/vm_configuration`, this since every configuration is very simple, and it would have been totally overkill to use a tool like Ansible.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

The main goal of this project being a reproducible and easy-to-deploy setup, most of the configurations are automatic and require little to none user interaction.

### Prerequisites

To successfully deploy the infrastructure, ensure you meet the following requirements:

1. **Proxmox Server**  
   - A computer running <img src="https://github.com/walkxcode/dashboard-icons/blob/main/png/proxmox.png?raw=true" style="width:15px;"> [Proxmox Virtual Environment](https://www.proxmox.com/) (tested on version 8.2).  
   - Ensure that the server is connected to the internet and has at least one separate Network Interface Card (NIC).

2. **Network Interface Configuration**  
   - **Motherboard NIC**: Reserved for internet access and Proxmox management - will be `vmbr0`.  
   - **PCIe NIC**: Dedicated to the *VPN-Gateway* virtual machine. This NIC should be configured to be passed through to the VM and exposed publicly for VPN access.

3. **Additional Requirements**  
   - Sufficient resources (CPU, RAM, and storage) to run the Proxmox environment and the planned virtual machines - in the base config, at least 8 CPU cores and 16 GB RAM.  
   - Access to a computer or device with Terraform installed (<img src="https://www.terraform.io/img/logo.png" style="width:15px;"> [Terraform installation guide](https://developer.hashicorp.com/terraform/tutorials)).  
   - SSH keys configured for secure access to Proxmox and other virtual machines.

4. **Terraform Environment**  
   - Terraform (version 1.9.8 or later, tested with version 1.9.8).  
   - The Terraform Proxmox provider configured. Install it via `terraform init` using the provided `proxmox` provider in this repo's `main.tf`.  


### Proxmox Authentication

The Terraform Proxmox provider uses API Token Key authentication. Before starting we need to create a user and generate an API token for that user (more info [here](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)). For this project, user creation, permissions, API Token generation and SSH keys are managed using `scripts/ssh_api_token_setup.sh`.

**It is mandatory to execute that script** - or generate manually a user, assign the correct permissions and generate an API Token - **before proceeding**. It will output the SSH keys, both public and private, in `ssh`, and will output in CLI the Proxmox API Token, which must be copied and will be used by Terraform as authentication.

The `api_token` that the provider accepts is in the form:

```json
api_token = "terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

Inside `terraform/terraform.tfvars` put the `api_token = "terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"`

### Network

Install guest agents on cloud image:

```bash
virt-customize -a noble-server-cloudimg-amd64.img --install qemu-guest-agent
```

The Proxmox Terraform provider we are using, despite being the one with the most features wrt API support, does not fully support the newly introduced SDN functionality of Proxmox (>= 8.0). For this reason we are using a bash script that leverages the `pvesh` command, a shell interface for the Proxmox VE API, more on that [here](https://pve.proxmox.com/pve-docs/pvesh.1.html).

The script can be found in `scripts/network_setup.sh`, but here is a short comment to better understand what it does:

1. Create a **simple zone**: 
   ```bash
   pvesh create /cluster/sdn/zones --type simple --zone "labnet" --dhcp "dnsmasq" --ipam "pve"
   ```
2. Create a **Virtual Network** within the previously created zone:
   ```bash
   pvesh create /cluster/sdn/vnets --vnet "labvnet" --zone "labnet"
   ```
3. Create a **subnet** for that Virtual Network:
   ```bash
   pvesh create /cluster/sdn/vnets/labvnet/subnets --subnet "10.10.10.0/24" --type "subnet" --gateway "10.10.10.1" --snat true --dhcp-range start-address=10.10.10.10,end-address=10.10.10.254
   ```
4. Apply SDN controller changes and reload:
   ```bash
   pvesh set /cluster/sdn
   ```

Simple Zones are explained into detail [here](https://pve.proxmox.com/wiki/Setup_Simple_Zone_With_SNAT_and_DHCP).

### Installation

External NIC to VPN Gateway:

`qm set 111 -hostpci0 0000:04:00.0`

Install EMQX:

```bash
curl -s https://assets.emqx.com/scripts/install-emqx-deb.sh | sudo bash && sudo apt-get install emqx && sudo systemctl start emqx && sudo emqx start
```

Routes for VPN gateway:

`sudo ip route add 10.10.10.0/24 dev eth0`

Interface for VPN gateway:

`sudo sed -i '/eth0:/a\    ens16f0:\n      dhcp4: true' /etc/netplan/50-cloud-init.yaml && sudo netplan apply`


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [x] Automatically configure networking
- [x] Automatically generate API Token
- [x] Download and patch Ubuntu Cloud image w/ `qemu-guest-agent`
- [x] Deploy VMs
- [x] Deploy firewall rules 
- [ ] Provision VMs
  - [ ] VPN Gateway
  - [x] MQTT Broker
  - [ ] CoAP Server
  - [ ] File Server
- [ ] Stress test the infrastructure

See the [open issues](https://github.com/GiovanniBaccichet/ANT-net/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


<!-- LICENSE -->
## License

Distributed under the GPLv3 License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Giovanni Baccichet - giovanni.baccichet@polimi.it

Project Link: [https://github.com/GiovanniBaccichet/ANT-Net](https://github.com/GiovanniBaccichet/ANT-Net)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

- Proxmox

<p align="right">(<a href="#readme-top">back to top</a>)</p>