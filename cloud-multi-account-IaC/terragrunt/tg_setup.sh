#!/bin/bash

TERRAGRUNT_VERSION=0.39.1

wget https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64
mv terragrunt_linux_amd64 terragrunt
sudo chmod u+x terragrunt
sudo mv terragrunt /usr/local/bin/terragrunt
