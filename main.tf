# MIT License
# Copyright (c) 2020 Jack Rayner <me@jrayner.net>

# Configure the DigitalOcean Provider
provider "digitalocean" {
}

terraform {
  backend "s3" {}
}

data "template_file" "tiddlywiki_user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"
  vars = {
    hostname      = var.hostname
    domain        = var.domain
    certbot_email = var.certbot_email
  }
}

resource "digitalocean_droplet" "tiddlywiki_server" {
  image     = "ubuntu-18-04-x64"
  name      = var.hostname
  region    = var.droplet_region
  size      = var.droplet_size
  ssh_keys  = var.ssh_keys
  tags      = var.tags
  user_data = data.template_file.tiddlywiki_user_data.rendered
}

resource "digitalocean_record" "tiddlywiki_server" {
  domain = var.domain
  name   = var.hostname
  type   = "A"
  value  = digitalocean_droplet.tiddlywiki_server.ipv4_address
}

output "tiddlywiki_server" {
  value = digitalocean_droplet.tiddlywiki_server.ipv4_address
}
