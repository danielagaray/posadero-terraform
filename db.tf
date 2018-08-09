#--------------------------------------------------------------
# This module creates all db servers
#--------------------------------------------------------------
resource "aws_security_group" "db" {
  name        = "posadero"
  vpc_id      = "${aws_vpc.posadera.id}"
  description = "Security group for posadero db Servers"

  tags      { Name = "posadero-db" }
  lifecycle {
      ignore_changes        = ["tags","name","description"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db" {
  name       = "main"
  subnet_ids = ["${aws_subnet.private.*.id}"]

  tags {
    Name = "RDS posadero subnet group"
  }
}

resource "aws_db_instance" "db" {
  allocated_storage    = "${var.rds_storage_size}"
  storage_type         = "gp2"
  engine               = "mysql"
  instance_class       = "${var.rds_instance_type}"
  identifier           = "dbposadero"
  name                 = "posadero"
  username             = "${var.rds_username}"
  password             = "${var.rds_password}"
  db_subnet_group_name = "${aws_db_subnet_group.db.name}"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  backup_retention_period = 14
  backup_window           = "01:00-03:00"
  multi_az                = false
  vpc_security_group_ids  = ["${aws_security_group.db.id}"]
}
