
terraform {
  backend "s3" {
    bucket       = "url-shortener-remote-tf-state"
    key          = "mindful-motion/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true //state locking 
  }
}
