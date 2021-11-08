provider "aws" {
  region     = "us-east-1"
  access_key = "${var.prod_access_key}"
  secret_key = "${var.prod_secret_key}"
}

provider "aws" {
  alias = "guest"
  region = "us-east-1"
  profile = "guest"
  access_key = "${var.guest_access_key}"
  secret_key = "${var.guest_secret_key}"
}

data "aws_caller_identity" "guest" {
  provider = "aws.guest"

}

data "aws_caller_identity" "current" {}



module "s3_cross_accout_module" {
  source = ".//S3_Cross_Account_Module"
}

