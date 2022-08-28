#!/bin/bash

set -e 

packer init .
packer validate -var-file="vars.ubuntu.pkrvars.hcl" .
packer build -var-file="vars.ubuntu.pkrvars.hcl" .