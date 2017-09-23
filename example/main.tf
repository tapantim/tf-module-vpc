
provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "azs" {}

module "vpc" {
  source = ".."
  availability_zones = "${data.aws_availability_zones.azs.names}"
  name_prefix = "test"
  vpc_cidr_block = "10.0.0.0/8"
  nat_gateway = "multi-az-gateway"

}