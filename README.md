# Terraform TiddlyWiki

This project is for deploying a basic [TiddlyWiki Server](https://tiddlywiki.com/static/WebServer.html) on DigitalOcean using Terraform. This project is still very much in its infancy so is subject to major changes.

## Variables
```
hostname = "myfirstwiki"
domain = "example.com"
certbot_email = "i.c.weiner@example.com"
ssh_keys = ["aa:bb:cc"]
droplet_size = "s-1vcpu-1gb"
droplet_region = "lon1"
tags = ["production"]
```

## Configuring the DigitalOcean S3/Spaces backend

Currently, the S3 backend does not play nicely with other "S3 compatible" services such as DigitalOcean Spaces by defualt. Therefore, it is necessary to set a few parameters as mentioned in a post [here](https://www.digitalocean.com/community/questions/spaces-as-terraform-backend).

### Example S3 Backend Configuration:
```
bucket = "example-bucket"
key    = "some_directory/terraform.tfstate"
region = "eu-central-1"
endpoint = "https://fra1.digitaloceanspaces.com"
profile = "digital_ocean_spaces_profile"
skip_credentials_validation = true
skip_get_ec2_platforms = true
skip_requesting_account_id = true
skip_metadata_api_check = true
```
### Setting up Spaces credentials
To pass credentials safely into Terraform for the backend, the easiest way to do it is to set the `profile` Terraform parameter and store the DigitalOcean Spaces credentials in the `~/.aws/credentials` file under a different profile. For example, I use: `do_spaces_key`.

_**Example `~/.aws/credentials`:**_
```
[default]
aws_access_key_id = XXXXXYYYYYY
aws_secret_access_key = XXX1111YYYYY88888

[do_spaces_key]
aws_access_key_id = AAAAABBBBBCCC
aws_secret_access_key = 11111AAAAA222222BBBBB
```
