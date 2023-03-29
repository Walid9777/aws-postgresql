provider "aws" {
  region = "eu-west-1"
}



resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "example_subnet_a" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.example.id
  availability_zone = "eu-west-1a"

  tags = {
    Name = "example-subnet-a"
  }
}

resource "aws_subnet" "example_subnet_b" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.example.id
  availability_zone = "eu-west-1b"

  tags = {
    Name = "example-subnet-b"
  }
}

resource "aws_db_subnet_group" "example" {
  name       = "postgres-subnet-group"
  subnet_ids = [aws_subnet.example_subnet_a.id, aws_subnet.example_subnet_b.id]

  tags = {
    Name = "example-db-subnet-group"
  }
}

resource "aws_security_group" "example" {
  name        = "example"
  description = "Example security group for RDS"
  vpc_id      = aws_vpc.example.id
}

resource "aws_security_group_rule" "example" {
  security_group_id = aws_security_group.example.id

  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_db_instance" "example" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13.3"
  instance_class       = "db.t3.micro"
  name                 = "example"
  username             = "example123"
  password             = "example12345"
  parameter_group_name = "default.postgres13"
  db_subnet_group_name = aws_db_subnet_group.example.name

  vpc_security_group_ids = [aws_security_group.example.id]

  skip_final_snapshot = true
}
