terraform {
  backend "s3" {
    bucket         = "flo-tf-boot-bucket"
    key            = "infra-aws/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "bootstrap-dynamodb-table"
  }
}