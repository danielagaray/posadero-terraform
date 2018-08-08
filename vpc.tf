#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "posadera" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "eks-posadera-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "public" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.posadera.id}"

  tags = "${
    map(
     "Name", "eks-posadera-public",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "private" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index + 2}.0/24"
  vpc_id            = "${aws_vpc.posadera.id}"

  tags = "${
    map(
     "Name", "eks-posadera-private",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "posadera" {
  vpc_id = "${aws_vpc.posadera.id}"

  tags {
    Name = "eks-posadera"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.posadera.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.posadera.id}"
  }

  tags {
    Name = "eks-posadera-public"
  }
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "nat" {
  vpc   = true
  lifecycle { create_before_destroy = true }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, 1)}"
  lifecycle { create_before_destroy = true }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.posadera.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name = "eks-posadera-private"
  }
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = "${aws_subnet.private.*.id[count.index]}"
  route_table_id = "${aws_route_table.private.id}"
}
