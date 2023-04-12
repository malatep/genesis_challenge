terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0" #locking to specific version
    }
  }
}

# assuming the default environment is DEV and it uses the local AWS credentials 
provider "aws" {
  alias  = "DEV"
  region = var.region
}


# creating different providers for additional environments (QA, STAGING, PROD). 
# Terraform will use the local AWS credentials to assume a pre-existing IAM role in the target account to deploy the resource there
provider "aws" {
  alias  = "QA"
  region = var.region
  assume_role {
    role_arn     = "arn:aws:iam::<QA_ACCOUNT_ID>:role/<QA_ROLE_NAME>"
    session_name = "qa_account"
  }
}

provider "aws" {
  alias  = "STAGING"
  region = var.region
  assume_role {
    role_arn     = "arn:aws:iam::<STAGING_ACCOUNT_ID>:role/<STAGING_ROLE_NAME>"
    session_name = "staging_account"
  }
}

provider "aws" {
  alias  = "PROD"
  region = var.region
  assume_role {
    role_arn     = "arn:aws:iam::<PROD_ACCOUNT_ID>:role/<PROD_ROLE_NAME>"
    session_name = "prod_account"
  }
}