resource "aws_s3_bucket" "devopss3bucket_updated" {
  bucket = var.aws_s3_bucket_name

  tags = {
    Name        = "s3"
    Environment = "Dev"
  }
}