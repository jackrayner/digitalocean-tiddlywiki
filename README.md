# Terraform TiddlyWiki

## Configuring the backend

Currently, the S3 backend does not play nicely with other "S3 compatible" services such as DigitalOcean Spaces by defualt. Therefore, it is necessary to set a few parameters as mentioned in a post [here](https://www.digitalocean.com/community/questions/spaces-as-terraform-backend)

The options are:
```
skip_requesting_account_id = true
skip_credentials_validation = true
skip_get_ec2_platforms = true
skip_metadata_api_check = true
```

For getting the credentials to work correctly, the easiest way to do it is to use the `profile` parameter and store the DigitalOcean Spaces credentials in the `~/.aws/credentials` file under a different profile. For example, I use `do_spaces`.
