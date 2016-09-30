variable "aws_region" {
  type    = "string"
  default = "eu-west-1"
}

variable "aws_profile" {
  type    = "string"
  default = ""
}

variable "key_name" {
  type = "string"
  default = "id_rsa"
}

// settings only valid for eu-west-1
variable "subnet_azs" {
  type        = "map"
  description = "Availability zones for each subnet"

  default = {
    "0" = "a"
    "1" = "b"
    "2" = "c"
  }
}

variable "public_subnet_blocks" {
  type        = "map"
  description = "CIDR blocks for each subnet"

  default = {
    "0" = "10.1.1.0/24"
    "1" = "10.1.2.0/24"
    "2" = "10.1.3.0/24"
  }
}

variable "private_subnet_blocks" {
  type        = "map"
  description = "CIDR blocks for each subnet"

  default = {
    "0" = "10.1.4.0/24"
    "1" = "10.1.5.0/24"
    "2" = "10.1.6.0/24"
  }
}

variable "vpc_cidr_block" {
  type        = "string"
  description = "CIRD blocks for vpc"
  default     = "10.1.0.0/16"
}

variable "stage" {
  type = "string"
  default = "staging"
}

variable "route53_internal_domain" {
  type    = "string"
  default = ""
}

variable "num_public_subnets" {
  default = 3
}

variable "num_private_subnets" {
  type    = "string"
  default = 0
}

variable "num_nodes" {
  type    = "string"
  default = ""
}

variable "control_plane_num" {
  type    = "string"
  default = 1
}

variable "nodes_num" {
  type    = "string"
  default = 1
}

variable "k8s_token" {
  type = "string"
}
