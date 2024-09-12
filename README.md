# Packer Proxmox Debian 12

This repository contains Packer templates and related files for automating the creation of Debian 12 virtual machines on a Proxmox VE host.

## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Packer Configuration](#packer-configuration)
- [Usage](#usage)
    - [Configuration](#configuration)
    - [Execution](#execution)
- [Template Information](#template-information)
- [Notes](#notes)

## Introduction

Packer is an open-source tool for creating machine images from a single source configuration. This project leverages Packer to automate the creation of Debian 12 virtual machines (VMs) on a Proxmox VE host. By using Packer, you can ensure consistency and reproducibility in your VM builds.

## Prerequisites

Before using these Packer templates, ensure you have the following:

- [Packer](https://www.packer.io/downloads) installed on your local machine
- Access to a Proxmox VE host
- Proxmox API token with appropriate permissions (Privilege Separation)
- Network access from your local machine to the Proxmox VE host

Note: The Debian 12.7 ISO will be automatically downloaded to your Proxmox VE host during the build process.

## Packer Configuration

This project uses the Proxmox plugin for Packer. The required plugin configuration is specified in the Packer template as follows:

```hcl
packer {
    required_plugins {
        name = {
            version = "1.1.8"
            source  = "github.com/hashicorp/proxmox"
        }
    }
}
```

This configuration ensures that Packer uses version 1.1.8 of the Proxmox plugin from HashiCorp's GitHub repository. Make sure you have this plugin installed or let Packer install it automatically when you run the build command.

## Usage

### Configuration

1. Clone the repository:
   ```bash
   git clone https://github.com/HanidaM/Packer-Proxmox-Debian12.git
   cd Packer-Proxmox-Debian12
   ```

2. Customize VM template (mandatory):
   - Edit the `custom.pkvars.hcl` file to change the configuration of the virtual machine

### Execution

1. Validate your Packer template:
   ```bash
   packer validate -var-file=custom.pkvars.hcl debian.pkr.hcl
   ```

2. Build the VM template:
   ```bash
   packer build -on-error=ask -force -var-file=custom.pkvars.hcl debian.pkr.hcl
   ```

   The `-on-error=ask` flag will prompt you for action if an error occurs during the build process.

## Template Information

- **Debian Version**: 12.7
- **Default User**: `debian`
- **Default Password**: `zxcv1234`
- **Network Configuration**: Static IP, defined in the `boot_command` section of the Packer template

## Notes

- The `preseed.cfg` file, which automates the Debian installation process, is stored in a separate repository. You can find it [here](https://github.com/HanidaM/devops-boilerplates/blob/main/http/preseed.cfg).
- Make sure to review and customize the `preseed.cfg` file according to your specific requirements before building the VM template.
- It's recommended to change the default password after creating your VM from this template.
- The static network configuration in the `boot_command` may need to be adjusted based on your network environment.
- This template is specifically designed for Debian 12.7. If you need to use a different version, you may need to adjust the ISO URL and checksum in your Packer template.

For more detailed information on using Packer with Proxmox, refer to the [Packer documentation](https://www.packer.io/docs/builders/proxmox) and the [Proxmox documentation](https://pve.proxmox.com/pve-docs/).