terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket = "lidoror-final-project-bucket"
    key    = "tfstate-terra-manage.json"
    region = "us-west-2"
    dynamodb_table = "lidoror-manage_cluster_lock"
  }


  required_version = ">= 1.2.0"
}
