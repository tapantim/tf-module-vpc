locals {
  az_count        = "${length(var.availability_zones)}"
  subnet_count    = "${local.az_count * 2}"
  subnet_maskbits = "${ceil(log(local.subnet_count, 2))}"
  nat_gw_count    = "${var.nat_gateway == "no-nat" ? 0 : var.nat_gateway == "single-az-nat" ? 1 : local.az_count}"
}

data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

data "aws_vpc_endpoint_service" "dynamodb" {
  service = "dynamodb"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = "${var.vpc_enable_dns_hostnames}"
  enable_dns_support   = "${var.vpc_enable_dns_support}"
  instance_tenancy     = "${var.vpc_instance_tenancy}"

  tags {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = "${local.az_count}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  availability_zone       = "${var.availability_zones[count.index]}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr_block, local.subnet_maskbits, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name_prefix}-public-subnet-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = "${local.az_count}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  availability_zone       = "${var.availability_zones[count.index]}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr_block, local.subnet_maskbits, count.index + 3)}"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.name_prefix}-private-subnet-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${var.name_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_associations" {
  count          = "${aws_subnet.public_subnets.count}"
  route_table_id = "${aws_route_table.public_route_table.id}"
  subnet_id      = "${aws_subnet.public_subnets.*.id[count.index]}"
}

resource "aws_eip" "nat_eip" {
  count = "${local.nat_gw_count}"
  vpc      = true
}

resource "aws_nat_gateway" "nat_gateway" {
  count = "${local.nat_gw_count}"
  allocation_id = "${aws_eip.nat_eip.*.id[count.index]}"
  subnet_id     = "${aws_subnet.public_subnets.*.id[count.index]}"
  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "private_route_table" {
  count  = "${aws_subnet.private_subnets.count}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat_gateway.*.id, count.index)}"
  }

  tags {
    Name = "${var.name_prefix}-private-route-table-${var.availability_zones[count.index]}"
  }
}

resource "aws_vpc_endpoint" "private-s3" {
  count        = "${var.vpc_s3_endpoint == true ? 1 : 0}"
  vpc_id       = "${aws_vpc.vpc.id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
}

resource "aws_vpc_endpoint" "private-dynamodb" {
  count        = "${var.vpc_dynamodb_endpoint == true ? 1 : 0}"
  vpc_id       = "${aws_vpc.vpc.id}"
  service_name = "${data.aws_vpc_endpoint_service.dynamodb.service_name}"
}