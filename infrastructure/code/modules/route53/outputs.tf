output "app_hosted_zone" {
  value       = aws_route53_zone.app_hosted_zone
  description = "Platground hosted zone created by this module"
}