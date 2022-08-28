#!/bin/bash

set -e 

packer init .
packer validate -var-file="vars.centos.pkrvars.hcl" .
packer build -var-file="vars.centos.pkrvars.hcl" .