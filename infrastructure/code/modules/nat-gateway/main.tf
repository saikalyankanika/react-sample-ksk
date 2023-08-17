locals {
  availability_zones = [for az in var.vpc_data.availability_zones : az.az_name]
}

# create elastic ips. These eip will be used for the nat-gateways in the public subnets
resource "aws_eip" "this" {
  for_each = toset(local.availability_zones)

  domain = "vpc"

  tags = {
    Name = "nat-gateway-${each.key}-eip"
  }
}

# create nat gateways in each public subnet
resource "aws_nat_gateway" "this" {
  for_each = toset(local.availability_zones)

  allocation_id = aws_eip.this[each.key].id
  subnet_id     = var.public_subnets[each.key].id

  tags = {
    Name = "nat-gateway-${each.key}"
  }
}

# create private route tables and add route through nat gateways
resource "aws_route_table" "private" {
  for_each = toset(local.availability_zones)

  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }

  tags = {
    Name = "private-route-table-${each.key}"
  }
}

# associate private app subnets with private route tables
resource "aws_route_table_association" "private_app_subnets" {
  for_each = toset(local.availability_zones)

  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = var.private_app_subnets[each.key].id
}

# associate private db subnets with private route tables
resource "aws_route_table_association" "private_db_subnets" {
  for_each = toset(local.availability_zones)

  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = var.private_db_subnets[each.key].id
}
