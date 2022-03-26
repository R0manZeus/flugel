provider "aws" {}

resource "aws_s3_bucket" "my-bucket" {
  bucket = "flugel-bucket"
  tags = {
    Name  = "Flugel"
    Owner = "InfraTeam"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.my-bucket.id
  acl    = "private"
}
