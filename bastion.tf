#--------------------------------------------------------------
# This module creates all bastion servers
#--------------------------------------------------------------

resource "aws_security_group" "bastion" {
  name        = "posadera-bastion"
  vpc_id      = "${aws_vpc.posadera.id}"
  description = "Security group for posadera Bastion Servers"

  tags      { Name = "posadera-bastion" }
  lifecycle {
      ignore_changes        = ["tags","name","description"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "template_file" "user_data" {
  template = "${file("userdata/ubuntu.yml.tpl")}"
  lifecycle {
    ignore_changes        = ["vars"]
  }
}

data "aws_ami" "bastion" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "bastion" {
  key_name = "posadero-2018"
  public_key = "${var.pub_key}"
}

resource "aws_instance" "bastion" {
    ami                     = "${data.aws_ami.bastion.id}"
    subnet_id               = "${element(aws_subnet.public.*.id, 1)}"
    instance_type           = "t1.micro"
    user_data               = "${template_file.user_data.rendered}"
    key_name                = "posadero-2018"
    vpc_security_group_ids  = ["${aws_security_group.bastion.id}"]
    disable_api_termination = "true"
    lifecycle {
        create_before_destroy = true
          ignore_changes        = ["tags","user_data","ami"]
    }
    tags {
        Name                  = "posadero-bastion"
    }
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
}
