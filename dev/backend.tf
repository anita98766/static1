terraform {
  backend "s3" {
    bucket         = "myfirstbucket5aa"
    key            = "dev/terraform.tfstate"  # State files for each workspace
    region         = "ap-south-1"

  }
}
