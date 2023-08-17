output "region" {
  value = var.region
}

output "project_name" {
  value = var.project_name
}

output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC id for the VPC created by this module"
}

output "public_subnets" {
  value       = aws_subnet.public
  description = "Public subnets created by this module"
}

output "private_app_subnets" {
  value       = aws_subnet.private_app
  description = "Private app subnets created by this module"
}

output "private_db_subnets" {
  value       = aws_subnet.private_db
  description = "Private db subnets created by this module"
}