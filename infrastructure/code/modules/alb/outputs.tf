output "alb_zone_id" {
  value       = aws_lb.alb.zone_id
  description = "Zone Id for the load balancer created by this module"
}

output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "DNS name for the load balancer created by this module"
}

output "alb_security_group_id" {
  value       = aws_security_group.load_balancer.id
  description = "Id of the security group for the load balancer created by this module"
}

output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
  description = "ARN for the target group created by this module"
}

