provider "aws" {  
    region     = var.region
}
  
terraform {
 backend "s3" {
 encrypt = true
 bucket = var.bucket
 region = var.region
 key = var.key
 }
}
