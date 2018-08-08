#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_ecr_repository" "app" {
  name  = "posadero-web"
}

resource "aws_ecr_repository" "nginx" {
  name  = "posadero-nginx"
}

resource "aws_iam_policy" "posadera-cluster-link" {
  name        = "posadera-cluster-link"
  path        = "/"

  policy = <<EOF
{
     "Version": "2012-10-17",
     "Statement": [
         {
             "Effect": "Allow",
             "Action": "iam:CreateServiceLinkedRole",
             "Resource": "arn:aws:iam::*:role/aws-service-role/*"
         },
         {
             "Effect": "Allow",
             "Action": [
                 "ec2:DescribeAccountAttributes"
             ],
             "Resource": "*"
         }
     ]
 }
EOF
}

resource "aws_iam_role" "posadera-cluster" {
  name = "eks-posadera-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "posadera-cluster-AmazonEKSLinkService" {
  policy_arn = "${aws_iam_policy.posadera-cluster-link.arn}"
  role       = "${aws_iam_role.posadera-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "posadera-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.posadera-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "posadera-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.posadera-cluster.name}"
}

resource "aws_security_group" "posadera-cluster" {
  name        = "eks-posadera-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.posadera.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "eks-posadera"
  }
}

resource "aws_security_group_rule" "posadera-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.posadera-cluster.id}"
  source_security_group_id = "${aws_security_group.posadera-node.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "posadera-cluster-ingress-workstation-https" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.posadera-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "posadera" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.posadera-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.posadera-cluster.id}"]
    subnet_ids         = ["${aws_subnet.private.*.id}","${aws_subnet.public.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.posadera-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.posadera-cluster-AmazonEKSServicePolicy",
  ]
}
