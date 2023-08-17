output "ecs_service_security_group_id" {
  value       = aws_security_group.service.id
  description = "Id of the security group for the ECS service created by this module"
}