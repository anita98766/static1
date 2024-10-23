terraform {
  backend "s3" {
    bucket         = "myfirstbucket5aa"
    key            = "prod/terraform.tfstate"  # State files for each workspace
    region         = "ap-south-1"
  }
}