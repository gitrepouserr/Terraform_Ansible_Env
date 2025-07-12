resource "aws_s3_bucket" "my_bucket" {
  bucket = "${var.env}-tws-junoon-app-bucket"
  tags = {
    Name = "${var.env}-tws-junoon-app-bucket"
    Environment = var.env
  }
}