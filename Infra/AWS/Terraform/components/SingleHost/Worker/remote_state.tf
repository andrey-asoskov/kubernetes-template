data "terraform_remote_state" "VPC" {
  backend = "local"

  config = {
    path = "../VPC/terraform.tfstate"
  }
}

data "terraform_remote_state" "CP" {
  backend = "local"

  config = {
    path = "../CP/terraform.tfstate"
  }
}
