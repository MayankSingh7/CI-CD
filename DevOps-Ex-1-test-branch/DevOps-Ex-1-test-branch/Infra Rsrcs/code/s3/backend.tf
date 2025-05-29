terraform {
  backend "s3" {
    bucket   = "atlantis-state-file-is-stored-here"
    key      = "atlantis-state-file-is-stored-here.tfstate"
    region   = "us-east-1"
    dynamdb  = "terraform-locks"
  }
}
