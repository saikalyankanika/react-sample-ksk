module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = ["yasser-abbasi-git/ecs-fargate-poc", "yasser-abbasi-git/cloud-task"]
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::174273434682:policy/sample-app-terraform-policy"]
}