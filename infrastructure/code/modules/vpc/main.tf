locals {
  availability_zones = [for az in var.vpc_data.availability_zones : az.az_name]
}

# create vpc
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_data.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# create public subnets
resource "aws_subnet" "public" {
  for_each = {
    for az in var.vpc_data.availability_zones :
    az.az_name => az
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.public_subnet_cidr
  availability_zone       = each.value.az_name
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${each.value.az_name}"
  }
}

# create private app subnets
resource "aws_subnet" "private_app" {
  for_each = {
    for az in var.vpc_data.availability_zones :
    az.az_name => az
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.private_app_subnet_cidr
  availability_zone       = each.value.az_name
  map_public_ip_on_launch = true

  tags = {
    Name = "private-app-subnet-${each.value.az_name}"
  }
}

# create private db subnets
resource "aws_subnet" "private_db" {
  for_each = {
    for az in var.vpc_data.availability_zones :
    az.az_name => az
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.private_db_subnet_cidr
  availability_zone       = each.value.az_name
  map_public_ip_on_launch = true

  tags = {
    Name = "private-db-subnet-${each.value.az_name}"
  }
}

# create internet gateway and attach it to vpc
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# create route table and add public route
resource "aws_route_table" "public" {
  for_each = {
    for az in var.vpc_data.availability_zones :
    az.az_name => az
  }

  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "public-route-table-${each.value.az_name}"
  }
}

# associate public subnets to "public route table"
resource "aws_route_table_association" "public_subnets" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[each.key].id
}

module "endpoints" {
  source             = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  vpc_id             = aws_vpc.this.id
  security_group_ids = [var.ecs_service_security_group_id]

  endpoints = {
    ecr-dkr = {
      service            = "ecr.dkr"
      security_group_ids = [var.ecs_service_security_group_id]
      subnet_ids         = [for subnet in aws_subnet.private_app : subnet.id]
      tags               = { Name = "ecr.dkr-vpc-endpoint" }
    },
    ecr-api = {
      service            = "ecr.api"
      security_group_ids = [var.ecs_service_security_group_id]
      subnet_ids         = [for subnet in aws_subnet.private_app : subnet.id]
      tags               = { Name = "ecr.api-vpc-endpoint" }
    },
    ecs-agent = {
      service            = "ecs-agent"
      security_group_ids = [var.ecs_service_security_group_id]
      subnet_ids         = [for subnet in aws_subnet.private_app : subnet.id]
      tags               = { Name = "ecs-agent-vpc-endpoint" }
    },
    ecs-telemetry = {
      service            = "ecs-telemetry"
      security_group_ids = [var.ecs_service_security_group_id]
      subnet_ids         = [for subnet in aws_subnet.private_app : subnet.id]
      tags               = { Name = "ecs-telemetry-vpc-endpoint" }
    }
  }
}