

data "amazon-ami" "data_ami" {
  filters = {
    name = "*${var.baseos_aminame}*"
    architecture = "${var.baseos_arch}"

    virtualization-type = "hvm"
  }
  owners      = ["${var.baseos_owner}"]
  most_recent = true
  region      = "${var.region}"
}

locals {
  date = formatdate("YYYYMMDD-hhmmss", timestamp())
}

source "amazon-ebs" "source_ebs" {
  ami_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    encrypted             = true
    volume_size           = var.volume_size
    volume_type           = "gp2"
  }
  ami_description = "${var.purpose} ${var.baseos_name} ${var.baseos_version} ${var.owner_name}"

  ami_name                    = "${var.purpose}-${var.baseos_name}-${var.baseos_version}-${var.baseos_arch}-${var.owner_name}-${local.date}"
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = false
  instance_type               = var.instance_type
  region                      = var.region
  source_ami                  = data.amazon-ami.data_ami.id
  ssh_pty                     = true
  ssh_username                = var.baseos_sshuser
  force_deregister            = true
  force_delete_snapshot       = true
}


build {
  description = "Packer AMI Builder ${var.owner_name}"

  sources = ["source.amazon-ebs.source_ebs"]

}
