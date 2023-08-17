resource "aws_iam_policy" "sample_app_terraform" {
  name   = "SampleAppTerraformAccess"
  policy = file("./policies/sample-app-terraform-policy.json")
}

module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = var.repositories
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds", aws_iam_policy.sample_app_terraform.arn]
}

resource "aws_ecr_repository" "this" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}