# Terraform TiddlyWiki

This project is for deploying a basic
[TiddlyWiki Server](https://tiddlywiki.com/static/WebServer.html) on DigitalOcean
using Terraform. This project is still very much in its infancy so is subject to
major changes.

## Prerequisites

To deploy this project, you will need the following requirements to be
satisfied:

- Terraform in your path.
- Terraform variables file.
- Terraform backend configuration file.
- [DigitalOcean Access Key](https://github.com/jackrayner/digitalocean-tiddlywiki/blob/master/README.md#access-key).
- [DigitalOcean Spaces Access Key](https://github.com/jackrayner/digitalocean-tiddlywiki/blob/master/README.md#spaces-access-key).

## Setup

```
git clone git@github.com:jackrayner/digitalocean-bookstack.git
cp s3_backend_example.tf backend.tf && vim backend.tf
cp example.tfvars vars.tfvars && vim vars.tfvars
terraform init -reconfigure -backend-config=backend.tf
```

## Deploy

```
terraform plan -var-file=vars.tfvars
terraform apply -var-file=vars.tfvars
```


## Configuring DigitalOcean Access Keys

### Access Key (with `doctl`)

The [DigitalOcean Provider](https://www.terraform.io/docs/providers/do/index.html)
will read the `DIGITALOCEAN_TOKEN` and `DIGITALOCEAN_ACCESS_TOKEN` environment
variables by default.

- Create an access key using [this](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/)
  guide.
- Run: `export DIGITALOCEAN_TOKEN=<TOKEN>`

#### Alternative export using existing `doctl` config

- Install `doctl` using [this](https://github.com/digitalocean/doctl/blob/master/README.md#installing-doctl)
  guide.
- Create an access key using [this](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/)
  guide.
- Authenticate `doctl` using the newly created key using [this](https://github.com/digitalocean/doctl/blob/master/README.md#authenticating-with-digitalocean)
  guide.
- Add an export to your `.bashrc` such as the statement below (macOS example):
```
if [[ -f ${HOME}/Library/Application\ Support/doctl/config.yaml ]]; then
    export DIGITALOCEAN_TOKEN="$(cat ${HOME}/Library/Application\ Support/doctl/config.yaml | awk 'IF $1 == "access-token:" {print $2}')"
fi
```

### Spaces Access Key

The easiest way to use Spaces credentials with the S3 backend is to create a new
profile in `~/.aws/credentials` and set the `profile` parameter in the S3
provider block. This is because Terraform will read this file by default.

#### Instructions

- Create a new Spaces Access Key using [this](https://www.digitalocean.com/community/tutorials/how-to-create-a-digitalocean-space-and-api-key#creating-an-access-key)
  guide.
- Create `~/.aws/credentials` and add an additional profile similar to below,
  replacing the `key_id` and `access_key` with you own credentials.
```
[do_spaces_key]
aws_access_key_id = AAAAABBBBBCCC
aws_secret_access_key = 11111AAAAA222222BBBBB
```
- In the backend config file, set `profile = "YOUR_PROFILE_NAME"`.

## Configuring the DigitalOcean Spaces backend

Currently, the Terraform S3 backend does not play nicely with other
"S3 compatible" services such as DigitalOcean Spaces by default. Therefore, it
is necessary to set a few addtional parameters as mentioned in
[this](https://www.digitalocean.com/community/questions/spaces-as-terraform-backend)
post.

### Example S3 Backend Configuration:
```
bucket                      = "example-bucket"
key                         = "some_directory/terraform.tfstate"
region                      = "eu-central-1"
endpoint                    = "https://fra1.digitaloceanspaces.com"
profile                     = "digital_ocean_spaces_profile"
skip_credentials_validation = true
skip_get_ec2_platforms      = true
skip_requesting_account_id  = true
skip_metadata_api_check     = true
```
