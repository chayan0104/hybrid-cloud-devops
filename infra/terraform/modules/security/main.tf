resource "aws_security_group" "alb" {
  name   = "${var.name_prefix}-alb-sg"
  vpc_id = var.vpc_id
  description = "Security group for the public application load balancer"

  #tfsec:ignore:aws-ec2-no-public-ingress-sgr Public HTTP/HTTPS ingress is required for the internet-facing ALB.
  ingress {
    description = "Allow inbound HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tfsec:ignore:aws-ec2-no-public-ingress-sgr Public HTTP/HTTPS ingress is required for the internet-facing ALB.
  ingress {
    description = "Allow inbound HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow the ALB to reach VPC targets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}

resource "aws_security_group" "tomcat" {
  name   = "${var.name_prefix}-tomcat-sg"
  vpc_id = var.vpc_id
  description = "Security group for the Tomcat application server"

  ingress {
    description     = "Allow ALB traffic to Tomcat"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow Tomcat to reach internal services"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}

resource "aws_security_group" "rds" {
  name   = "${var.name_prefix}-rds-sg"
  vpc_id = var.vpc_id
  description = "Security group for the PostgreSQL database"

  ingress {
    description     = "Allow Tomcat to reach PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.tomcat.id]
  }

  ingress {
    description     = "Allow EKS workloads to reach PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks.id]
  }

  egress {
    description = "Allow RDS to communicate within the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}

resource "aws_security_group" "eks" {
  name   = "${var.name_prefix}-eks-sg"
  vpc_id = var.vpc_id
  description = "Security group for the private EKS control plane and nodes"

  #tfsec:ignore:aws-ec2-no-public-egress-sgr EKS nodes require outbound access for image pulls and managed service communication.
  egress {
    description = "Allow EKS managed components to reach required external services"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
