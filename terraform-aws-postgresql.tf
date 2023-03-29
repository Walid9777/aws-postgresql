provider "aws" {
  region = "eu-west-1"
}

locals {
  vpc_cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "postgres_vpc" {
  cidr_block = local.vpc_cidr_block
  tags = {
    Name = "postgres-vpc"
  }
}

resource "aws_subnet" "postgres_subnet_1" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.postgres_vpc.id
  tags = {
    Name = "postgres-subnet-1"
  }
}

resource "aws_subnet" "postgres_subnet_2" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.postgres_vpc.id
  tags = {
    Name = "postgres-subnet-2"
  }
}

resource "aws_security_group" "postgres_sg" {
  name        = "postgres-sg"
  description = "PostgreSQL database security group"
  vpc_id      = aws_vpc.postgres_vpc.id
}

resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres-subnet-group"
  subnet_ids = [aws_subnet.postgres_subnet_1.id, aws_subnet.postgres_subnet_2.id]

  tags = {
    Name = "postgres-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres_instance" {
  identifier           = "postgres-instance"
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "13.3"
  instance_class       = "db.t3.micro"
  name                 = "mypgdb"
  username             = "postgres"
  password             = "supersecretpassword"
  db_subnet_group_name = aws_db_subnet_group.postgres_subnet_group.name

  vpc_security_group_ids = [aws_security_group.postgres_sg.id]

  backup_retention_period = 7
  backup_window           = "07:00-09:00"
  maintenance_window      = "Mon:09:00-Mon:11:00"

  tags = {
    Name = "postgres-instance"
  }
}
