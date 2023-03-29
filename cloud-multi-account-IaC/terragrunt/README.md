# **Terragrunt**

## Install Terragrunt

### Quick setup

Run `./tg_setup.sh`


### Manual setup

```
wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.38.7/terragrunt_linux_amd64
mv terragrunt_linux_amd64 terragrunt
chmod u+x terragrunt
sudo cp terragrunt /usr/local/bin/terragrunt
```

> **NB** Terraform is installed by default on GCP Cloud Shell.

## Folder structure

Showing the folder structure using Composer service as an example.
Every other service or module should follow the same structure

```
├── terraform
|   ├── wrappers
|   |   ├── composer
│   |   │   ├── main.tf
│   |   │   ├── variables.tf
|   |   ├── <other terraform wrappers> ...
|   ├── modules
│   │   ├── composer
│   │   |   ├── main.tf
│   │   |   ├── variables.tf
│   │   ├── <other terraform gcp services modules > ... 
|
| ...
|
├── terragrunt
|   ├── preprod
│   |   ├── europe-west1
│   |   |   ├── cpsoi-01
│   │   |   |   ├── common
│   │   |   |   |   ├── terragrunt.hcl
│   │   |   |   |   ├── composer.tfvars
│   │   |   |   ├── <other gpc services cpsoi-01> ...
│   │   |   ├── <other project services> ...
│   │   ├── <other regions>...
|   ├── prod
│   |   ├── europe-west1
│   |   |   ├── cpsoi-01
│   │   |   |   ├── common
│   │   |   |   |   ├── terragrunt.hcl
│   │   |   |   |   ├── composer.tfvars
│   │   |   |   |   ├── <other gpc services tfvars> ...
│   │   |   |   ├── <other terragrunt configs per services> ...
│   │   |   |   |   ├── terragrunt.hcl
│   │   |   ├── <other project services> ...
│   │   ├── <other regions>...
└───
```

With this configuration, Terragrunt will take care for the backend configuration for each service project we have to maintain, allowing to us to generalize and slim our Terraform code. Further optimization or DRYing of the code will be applied step-by-step during the migration of the manual configuration already present in our projects.

> **Quick rule of thumb** <br>
> `terragrunt/` -> backends/providers confgurations and service projects variables <br>
> `terraform/` -> Terraform GCP infrastructure blueprint

<br>

## Roadmap

- [x] Repo folder structure
- [x] Rewriting/moving current variables and values in the correct place
- [x] Moving current existing states in the new remote folders
- [x] Implement Composer module for all the available/requested services
- [x] Full working test
- [ ] Align Terraform state of all possible services
- [ ] Add other GCP Terraform modules
- [ ] Interpolate modules to reduce manual variables
- [ ] Add KMS management in Terraform (for creation, maintenance and rotation)


## Troubleshooting

> Workaround https://github.com/hashicorp/terraform-provider-google/issues/6782
```bash
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 net.ipv6.conf.default.disable_ipv6=1 net.ipv6.conf.lo.disable_ipv6=1 > /dev/null
    export APIS=$(gcloud services list --available --filter="name:googleapis.com" --format "csv[no-heading](ID)" --format "value(NAME)" | tr '\n' ' ')
    for name in $APIS
    do
      ipv4=$(getent ahostsv4 "$name" | head -n 1 | awk '{ print $1 }')
      grep -q "$name" /etc/hosts || ([ -n "$ipv4" ] && sudo sh -c "echo '$ipv4 $name' >> /etc/hosts")
    done
```
