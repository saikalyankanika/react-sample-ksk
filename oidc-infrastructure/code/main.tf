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
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", aws_iam_policy.sample_app_terraform.arn]
}