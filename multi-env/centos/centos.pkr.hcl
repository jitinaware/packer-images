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

source "amazon-ebs" "centos7" {
  region = "us-east-2"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "*CentOS 7.9.2009*"
      root-device-type    = "ebs"
      architecture        = "x86_64"
    }
    owners      = ["125523088429"]
    most_recent = true
  }
  instance_type         = "t2.small"
  ssh_username          = "centos"
  ssh_agent_auth        = false
  force_deregister      = true
  force_delete_snapshot = true

  ami_name = "${var.purpose}-CentOS 7.9.2009-x64-${var.owner_name}-${local.date}"
  ami_regions = [
    #"us-east-1", 
    "us-east-2"
  ]
}


build {
  description = "Packer AMI Builder ${var.owner_name}"

  sources = ["source.amazon-ebs.centos7"]

  provisioner "file" {
    destination = "/tmp/"
    source      = "../scripts"
  }

  provisioner "shell" {
    inline = ["sudo /tmp/scripts/splunk/install-splunk-uf.sh"]
  }
}