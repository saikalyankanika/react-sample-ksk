terraform {
  backend "s3" {
    bucket         = "terraform-state-174273434682-eu-west-2"
    key            = "sample-app/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}