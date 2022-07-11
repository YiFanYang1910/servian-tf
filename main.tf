terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  #define terraform version

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ap-southeast-2"
  shared_credentials_files = ["/Users/sjq/.aws/credentials"]

}


module "back_end_terraform" {
  source = "./modules/"
  ecs_name = "jamesservian"
  ecr_name = "jamesservian"
  security_group = "jamesaserviansecgroup"
}
