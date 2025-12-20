terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # https://github.com/hashicorp/terraform-provider-aws/issues/39578 breaks aws_s3_bucket_lifecycle_configuration
      version = "< 5.70"
    }
    pass = {
      source  = "camptocamp/pass"
      version = "~> 2.1"
    }
  }
}
