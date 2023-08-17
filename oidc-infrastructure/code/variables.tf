variable "region" {
  description = "The default AWS region to use for provisioning infrastructure"
  type        = string
  default     = "eu-west-2"

  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.region))
    error_message = "Must be valid AWS region name"
  }
}