<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/GiovanniBaccichet/ANT-net">
    <img src="images/logo.png" alt="Logo" width="160">
  </a>

  <h3 align="center">ANT Net</h3>

  <p align="center">
    Infrastructure as Code (IaC) for Advanced Network Technologies (ANT) Didactic Lab
    <br />
    <a href="https://github.com/GiovanniBaccichet/ANT-net"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/GiovanniBaccichet/ANT-net">View Demo</a>
    ·
    <a href="https://github.com/GiovanniBaccichet/ANT-net/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/GiovanniBaccichet/ANT-net/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>



<!-- ABOUT THE PROJECT -->
## About The Project

![alt text](images/proxmox-infra.png)

There are many great README templates available on GitHub; however, I didn't find one that really suited my needs so I created this enhanced one. I want to create a README template so amazing that it'll be the last one you ever need -- I think this is it.

Here's why:
* Your time should be focused on creating something amazing. A project that solves a problem and helps others
* You shouldn't be doing the same tasks over and over like creating a README from scratch
* You should implement DRY principles to the rest of your life :smile:

Of course, no one template will serve all projects since your needs may be different. So I'll be adding more in the near future. You may also suggest changes by forking this repo and creating a pull request or opening an issue. Thanks to all the people have contributed to expanding this template!

Use the `BLANK_README.md` to get started.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

Terraform, Packer.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

Some manual steps are required in order to setup the infrastructure, since the Terraform Proxmox plugin does not support the whole set of APIs that the hypervisor provides.

1. Run `scripts/enable_dhcp_ipam.sh` script in order to allow Proxmox to assign the DHCP to the internal network, more on this [here](https://pve.proxmox.com/pve-docs/chapter-pvesdn.html#pvesdn_install_dhcp_ipam).
2. Datacenter -> SDN -> Zones: Add - Simple: ID = `labnet`
3. Datacenter -> SDN -> VNets: Create: Name: `labvnet` Zone: `labnet`
   1. Subnets: Create: `10.10.10.0/24` Gateway: `10.10.10.1` SNAT: Enable
4. SND -> Apply

### Prerequisites

The Terraform Proxmox provider uses API Token Key authentication. Before starting we need to create a user and generate an API token for that user (more info [here](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)):

1. Create the user with: 
   ```bash
   pveum user add terraform@pve
   ```
2. Create a role for the user: 
   ```bash
   pveum role add Terraform -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt User.Modify"
   ```
3. Assign the role to the previously created user: 
   ```bash
   pveum aclmod / -user terraform@pve -role Terraform
   ```
4. Create an API token for the user: 
   ```bash
   pveum user token add terraform@pve provider --privsep=0
   ```

Alternatively run the `scripts/generate__api_token.sh` bash script.

The `api_token` that the provider accepts is in the form:

```json
api_token = "terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### Installation



<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [x] Add Changelog
- [x] Add back to top links
- [ ] Add Additional Templates w/ Examples
- [ ] Add "components" document to easily copy & paste sections of the readme
- [ ] Multi-language Support
    - [ ] Chinese
    - [ ] Spanish

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

Your Name - [@your_twitter](https://twitter.com/your_username) - email@example.com

Project Link: [https://github.com/your_username/repo_name](https://github.com/your_username/repo_name)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Use this space to list resources you find helpful and would like to give credit to. I've included a few of my favorites to kick things off!

<p align="right">(<a href="#readme-top">back to top</a>)</p>
