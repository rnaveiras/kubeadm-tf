resource "aws_vpc" "platform" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name  = "platform-${var.stage}"
    Stage = "${var.stage}"
  }
}


// list of az which can be access from the current region
data "aws_availability_zones" "az" {
  state = "available"
}

resource "aws_vpc_dhcp_options" "platform" {
  domain_name         = "${var.aws_region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name  = "platform-${var.stage}"
    Stage = "${var.stage}"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.platform.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.platform.id}"
}

resource "aws_internet_gateway" "platform" {
  vpc_id = "${aws_vpc.platform.id}"

  tags {
    Name  = "platform-${var.stage}"
    Stage = "${var.stage}"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.platform.id}"
  availability_zone = "${element(data.aws_availability_zones.az.names, count.index)}"
  cidr_block        = "${lookup(var.public_subnet_blocks, count.index)}"
  count             = "${var.num_public_subnets}"

  tags {
    Name = "public-${element(data.aws_availability_zones.az.names, count.index)}"
  }

  map_public_ip_on_launch = true
  depends_on              = ["aws_main_route_table_association.main"]
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.platform.id}"
  availability_zone = "${element(data.aws_availability_zones.az.names, count.index)}"
  cidr_block        = "${lookup(var.private_subnet_blocks, count.index)}"
  count             = "${var.num_private_subnets}"

  tags {
    Name = "private-${element(data.aws_availability_zones.az.names, count.index)}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.platform.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.platform.id}"
  }

  tags {
    Name  = "platform-${var.stage}"
    Stage = "${var.stage}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.platform.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.platform.*.id, count.index)}"
  }

  tags {
    Name  = "${var.stage}-private-${element(data.aws_availability_zones.az.names, count.index)}"
    Stage = "${var.stage}"
  }

  count = "${var.num_private_subnets}"
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = "${aws_vpc.platform.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "main" {
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

  count = "${var.num_private_subnets}"
}

resource "aws_eip" "nat" {
  vpc = true

  count = "${var.num_private_subnets}"
}

resource "aws_nat_gateway" "platform" {
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  count = "${var.num_private_subnets}"
}
