
variable "name_prefix" {}

variable "availability_zones" {
  type = "list"
}

variable "vpc_cidr_block" {}

variable "nat_gateway" {
  default = "single-az-nat"
  description = "supported values are: no-nat, single-az-nat and multi-az-nat"
}

variable "vpc_enable_dns_support" {
  default = "true"
}

variable "vpc_enable_dns_hostnames" {
  default = "true"
}

variable "vpc_instance_tenancy" {
  default = "default"
}

variable "vpc_s3_endpoint" {
  default = "false"
}

variable "vpc_dynamodb_endpoint" {
  default = "false"
}
