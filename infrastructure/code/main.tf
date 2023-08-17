locals {
  app_hosted_zone_domain = "${var.app_hosted_zone_name}.${var.root_domain}"
  sample_app_domain      = "${var.app_subdomain}.${local.app_hosted_zone_domain}"
}

# create vpc
module "vpc" {
  source                        = "./modules/vpc"
  region                        = var.region
  project_name                  = var.project_name
  vpc_data                      = var.vpc_data
  ecs_service_security_group_id = module.ecs.ecs_service_security_group_id
}

# create nat gateway
module "nat_gateway" {
  source              = "./modules/nat-gateway"
  vpc_id              = module.vpc.vpc_id
  vpc_data            = var.vpc_data
  public_subnets      = module.vpc.public_subnets
  private_app_subnets = module.vpc.private_app_subnets
  private_db_subnets  = module.vpc.private_db_subnets
}

# create iam role
module "iam" {
  source = "./modules/iam"
}

module "route53" {
  source                 = "./modules/route53"
  root_domain            = var.root_domain
  app_hosted_zone_domain = local.app_hosted_zone_domain
  app_hosted_zone_name   = var.app_hosted_zone_name
  app_subdomain          = var.app_subdomain
  alb_dns_name           = module.alb.alb_dns_name
  alb_zone_id            = module.alb.alb_zone_id
}

# Create acm certificate
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name         = "*.${local.app_hosted_zone_domain}"
  zone_id             = module.route53.app_hosted_zone.zone_id
  wait_for_validation = true

  tags = {
    Name = "${local.sample_app_domain}"
  }

  depends_on = [
    module.route53.app_hosted_zone
  ]
}

# Create application load balancer
module "alb" {
  source              = "./modules/alb"
  public_subnets      = module.vpc.public_subnets
  vpc_id              = module.vpc.vpc_id
  project_name        = var.project_name
  app_name            = var.app_name
  acm_certificate_arn = module.acm.acm_certificate_arn
}

# Create ecs cluster, service and task definition
module "ecs" {
  source                          = "./modules/ecs"
  region                          = var.region
  project_name                    = var.project_name
  app_name                        = var.app_name
  private_app_subnets             = module.vpc.private_app_subnets
  vpc_id                          = module.vpc.vpc_id
  load_balancer_security_group_id = module.alb.alb_security_group_id
  target_group_arn                = module.alb.target_group_arn
  ecs_task_execution_role_arn     = module.iam.ecs_task_execution_role_arn
  image_path                      = var.image_path
  image_tag                       = var.image_tag
}