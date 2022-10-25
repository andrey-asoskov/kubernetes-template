data "terraform_remote_state" "VPC" {
  backend = "local"

  config = {
    path = "../VPC/terraform.tfstate"
  }
}
