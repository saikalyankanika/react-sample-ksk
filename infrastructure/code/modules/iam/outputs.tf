output "ecs_task_execution_role_arn" {
  value       = aws_iam_role.ecs_task_execution.arn
  description = "Role ARN for the ECS Task Execution role created by this module"
}

