
terraform {
  backend "s3" {
    bucket       = "employee-management-terraform-state"
    key          = "employee-management/dev/terraform.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
