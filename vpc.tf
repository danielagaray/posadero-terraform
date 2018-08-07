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

resource "aws_subnet" "posadera" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.posadera.id}"

  tags = "${
    map(
     "Name", "eks-posadera-node",
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

resource "aws_route_table" "posadera" {
  vpc_id = "${aws_vpc.posadera.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.posadera.id}"
  }
}

resource "aws_route_table_association" "posadera" {
  count = 2

  subnet_id      = "${aws_subnet.posadera.*.id[count.index]}"
  route_table_id = "${aws_route_table.posadera.id}"
}
