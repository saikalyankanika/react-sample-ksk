variable "region" {
  description = "The default AWS region to use for provisioning infrastructure"
  type        = string
  default     = "eu-west-2"

  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.region))
    error_message = "Must be valid AWS region name"
  }
}

variable "repositories"{
  description = "The repositories allowed to talk to AWS for OIDC integration"
  type = list
}

variable "ecr_repository_name"{
  description = "The name of the ECR repository to create"
  type = string
  default = "sample-app-docker-images"
}
