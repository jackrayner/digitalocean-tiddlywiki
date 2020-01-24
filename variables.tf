variable "hostname" {
    type = string
}

variable "domain" {
    type = string
}

variable "certbot_email" {
    type = string
}

variable "droplet_size" {
    type = string
}

variable "droplet_region" {
    type = string
}

variable "ssh_keys" {
    type = list(string)
}

variable "tags" {
    type = list(string)
}
