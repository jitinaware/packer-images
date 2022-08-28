packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.9"
    }
    azure = {
      source  = "github.com/hashicorp/azure"
      version = ">= 1.0.6"
    }
  }
}

locals {
  date = formatdate("YYYYMMDD-hhmmss", timestamp())
}

source "amazon-ebs" "ubuntu-focal" {
  region = "us-east-2"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*"
      root-device-type    = "ebs"
      architecture        = "x86_64"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false

  ami_name = "${var.purpose}-ubuntu-focal-20.04-x64-${var.owner_name}-${local.date}"
  ami_regions = [
    #"us-east-1", 
    "us-east-2"
  ]
}

source "azure-arm" "ubuntu-focal" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }

  client_id       = env.AZ_CLIENT_ID
  client_secret   = env.AZ_CLIENT_SECRET
  subscription_id = env.AZ_SUBSCRIPTION_ID

  # Must be created beforehand
  managed_image_resource_group_name = var.az_resource_group

  os_type         = "Linux"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_publisher = "Canonical"
  image_sku       = "20_04-lts-gen2"

  vm_size = "Standard_B1s"
}

build {
  description = "Packer AMI Builder ${var.owner_name}"

  #sources = ["source.amazon-ebs.ubuntu-focal"]

  source "source.azure-arm.ubuntu-focal" {
    build_resource_group_name = var.az_resource_group
    managed_image_name        = "${var.purpose}-ubuntu-focal-20.04-x64-${var.owner_name}-${local.date}"
  }

  provisioner "file" {
    destination = "/tmp/"
    source      = "../../scripts"
  }

  provisioner "shell" {
    inline = ["sudo /tmp/scripts/splunk/install-splunk-uf.sh"]
  }
}
