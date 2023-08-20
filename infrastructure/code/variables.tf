variable "region" {
  description = "The default AWS region to use for provisioning infrastructure"
  type        = string
  default     = "eu-west-2"

  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.region))
    error_message = "Must be valid AWS region name"
  }
}

variable "project_name" {
  description = "The name of the project used for tagging resources"
  type        = string
  default     = "ecs-fargate-poc"
}

variable "vpc_data" {
  description = "Variable to hold and object for vpc configuration"

  type = object({
    vpc_cidr = string
    availability_zones = list(object({
      az_name                 = string
      public_subnet_cidr      = string
      private_app_subnet_cidr = string
      private_db_subnet_cidr  = string
    }))
  })

  default = {
    vpc_cidr = "10.0.0.0/16"
    availability_zones = [{
      az_name                 = "eu-west-2a"
      public_subnet_cidr      = "10.0.0.0/20"
      private_app_subnet_cidr = "10.0.64.0/20"
      private_db_subnet_cidr  = "10.0.128.0/20"
      },
      {
        az_name                 = "eu-west-2b"
        public_subnet_cidr      = "10.0.16.0/20"
        private_app_subnet_cidr = "10.0.80.0/20"
        private_db_subnet_cidr  = "10.0.144.0/20"
      },
      {
        az_name                 = "eu-west-2c"
        public_subnet_cidr      = "10.0.32.0/20"
        private_app_subnet_cidr = "10.0.96.0/20"
        private_db_subnet_cidr  = "10.0.160.0/20"
    }]
  }
}

variable "root_domain" {
  description = "Root domain for the application"
  type        = string
  default     = "yasserabbasi.com"
}

variable "app_subdomain" {
  description = "Sub-domain for the application"
  type        = string
  default     = "web"
}

variable "app_name" {
  description = "Name of the application used for tagging resources"
  type        = string
  default     = "sample-app"
}

variable "app_hosted_zone_name" {
  description = "Name of the hosted zone for the application dns records"
  type        = string
  default     = "playground"
}

variable "image_path" {
  description = "Path to ECR"
  type        = string
  default     = "{AWS-accountID}.dkr.ecr.{region}.amazonaws.com/sample-app-docker-images"
}

variable "image_tag" {
  description = "The tag to fetch for the image from the repository"
  type        = string
  default     = "latest"
}