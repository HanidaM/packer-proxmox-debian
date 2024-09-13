packer {
    required_plugins {
        name = {
            version = "1.1.8"
            source  = "github.com/hashicorp/proxmox"
        }
    }
}

variable "bios_type" {
    type    = string
}

variable "boot_wait" {
    type    = string
    default = "10s"
}

variable "bridge_name" {
    type    = string
}

variable "vlan_tag" {
    type    = string
    default = "20"
}

variable "bridge_firewall" {
    type    = bool
    default = false
}

variable "cloud_init" {
    type    = bool
    default = false
}

variable "cpu_type" {
    type    = string
}

variable "disk_discard" {
    type    = bool
}

variable "disk_format" {
    type    = string
    default = "qcow2"
}

variable "disk_size" {
    type    = string
    default = "8G"
}

variable "disk_type" {
    type    = string
    default = "scsi"
}

variable "machine_default_type" {
    type    = string
    default = "Default (i440fx)"
}

variable "nb_core" {
    type    = number
    default = 1
}

variable "nb_cpu" {
    type    = number
    default = 1
}

variable "nb_ram" {
    type    = number
    default = 4096
}

variable "network_model" {
    type    = string
    default = "virtio"
}

variable "numa" {
    type    = bool
    default = true
}

variable "io_thread" {
    type    = bool
    default = false
}

variable "os_type" {
    type    = string
    default = "l26"
}

variable "proxmox_api_token_id" {
    type    = string
    default = ""
}

variable "proxmox_api_token_secret" {
    type      = string
    sensitive = true
}

variable "proxmox_api_url" {
    type    = string
}

variable "proxmox_node" {
    type    = string
}

variable "qemu_agent_activation" {
    type    = bool
    default = true
}

variable "scsi_controller_type" {
    type    = string
}

variable "ssh_handshake_attempts" {
    type    = number
    default = 6
}

variable "ssh_timeout" {
    type    = string
    default = "15m"
}

variable "ssh_username" {
    type    = string
    default = "debian"
}

variable "ssh_password" {
    type    = string
    default = "zxcv1234"
}

variable "storage_pool" {
    type    = string
}

variable "tags" {
    type    = string
    default = "template"
}

variable "vm_id" {
    type    = number
    default = 9000
}

variable "vm_info" {
    type    = string
    default = "Debian 12 Packer Template"
}

variable "vm_name" {
    type    = string
    default = "debian12-template"
}

variable "iso_storage_pool" {
    type    = string
    default = "local"
}

variable "iso_url" {
    type    = string
}

variable "iso_checksum" {
    type    = string
}


source "proxmox-iso" "debian12" {
    bios                     = "${var.bios_type}"
    boot_wait                = "${var.boot_wait}"
    cloud_init               = "${var.cloud_init}"
    cloud_init_storage_pool  = "${var.storage_pool}"
    communicator             = "ssh"
    cores                    = "${var.nb_core}"
    cpu_type                 = "${var.cpu_type}"
    insecure_skip_tls_verify = true
    iso_url                  = "${var.iso_url}"
    iso_checksum             = "${var.iso_checksum}"
    iso_storage_pool         = "${var.iso_storage_pool}"
    memory                   = "${var.nb_ram}"
    ssh_password             = "${var.ssh_password}"
    ssh_timeout              = "${var.ssh_timeout}"
    ssh_username             = "${var.ssh_username}"
    node                     = "${var.proxmox_node}"
    os                       = "${var.os_type}"
    proxmox_url              = "${var.proxmox_api_url}"
    qemu_agent               = "${var.qemu_agent_activation}"
    scsi_controller          = "${var.scsi_controller_type}"
    sockets                  = "${var.nb_cpu}"
    tags                     = "${var.tags}"
    token                    = "${var.proxmox_api_token_secret}"
    unmount_iso              = true
    username                 = "${var.proxmox_api_token_id}"
    vm_id                    = "${var.vm_id}"
    vm_name                  = "${var.vm_name}"
    numa                     = "${var.numa}"
    template_name            = "${var.vm_name}"

    boot_command = [
        "<wait><esc><wait>",
        "install <wait>",
        " preseed/url=https://raw.githubusercontent.com/HanidaM/devops-boilerplates/main/http/preseed.cfg <wait>",
        "debian-installer=en_US.UTF-8 <wait>",
        "auto <wait>",
        "locale=en_US.UTF-8 <wait>",
        "kbd-chooser/method=us <wait>",
        "keyboard-configuration/xkb-keymap=us <wait>",

        # static network config
        "netcfg/disable_autoconfig=true <wait>",
        "netcfg/use_autoconfig=false <wait>",
        "netcfg/get_ipaddress=192.168.1.10 <wait>",
        "netcfg/get_netmask=255.255.255.0 <wait>",
        "netcfg/get_gateway=192.168.1.1 <wait>",
        "netcfg/get_nameservers=8.8.8.8 <wait>",
        "netcfg/confirm_static=true <wait>",
        "netcfg/get_hostname=${var.vm_name} <wait>",
        "netcfg/get_domain= <wait>",

        "fb=false <wait>",
        "debconf/frontend=noninteractive <wait>",
        "console-setup/ask_detect=false <wait>",
        "console-keymaps-at/keymap=us <wait>",
        "grub-installer/bootdev=default <wait>",
        "<enter><wait>",
    ]

    disks {
        discard      = "${var.disk_discard}"
        disk_size    = "${var.disk_size}"
        format       = "${var.disk_format}"
        io_thread    = "${var.io_thread}"
        storage_pool = "${var.storage_pool}"
        type         = "${var.disk_type}"
    }

    network_adapters {
        bridge   = "${var.bridge_name}"
        vlan_tag = "${var.vlan_tag}"
        firewall = "${var.bridge_firewall}"
        model    = "${var.network_model}"
    }
}

build {
    sources = ["source.proxmox-iso.debian12"]


        provisioner "shell" {
        inline = [
            "sudo apt-get update -y",
            "sudo apt-get install qemu-guest-agent cloud-init -y",
            "sudo systemctl start qemu-guest-agent",
            "sudo systemctl start cloud-init",
            "echo 'QEMU Guest Agent and cloud-init installation and setup completed '"
        ]
    }

}