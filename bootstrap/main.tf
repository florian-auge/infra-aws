provider "aws" {
  region = "eu-west-3"
}

resource "aws_s3_bucket" "tf_main"{
    bucket = "flo-tf-boot-bucket"

    tags = {
        Name        = "Bootstrap Terraform Bucket"
        Environment = "Devops"
    }
}

resource "aws_dynamodb_table" "boot-dynamodb-table"{
    name         = "bootstrap-dynamodb-table"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    
}