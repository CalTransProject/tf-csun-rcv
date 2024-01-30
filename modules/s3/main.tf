locals {
  bucket_name = var.bucket_name == null ? "rcv${formatdate("ssmmhhDDMM", timestamp())}" : var.bucket_name
}

# public bucket
resource "aws_s3_bucket" "rcv" {
  bucket = local.bucket_name
  tags = {
    Name = local.bucket_name
  }

  lifecycle {
    ignore_changes = [bucket, tags]
  }
}

# public access block
resource "aws_s3_bucket_public_access_block" "rcv" {
  bucket                  = aws_s3_bucket.rcv.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# bucket policy
resource "aws_s3_bucket_policy" "rcv" {
  bucket = aws_s3_bucket.rcv.id
  policy = jsonencode({
    "Version" = "2012-10-17"
    "Id"      = "BUCKET-POLICY"
    "Statement" = [
      {
        "Sid" : "PublicReadForGetBucketObjects",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.rcv.arn}/*"
      },
      {
        "Sid"       = "EnforceTls"
        "Effect"    = "Deny"
        "Principal" = "*"
        "Action"    = "s3:*"
        "Resource" = [
          "${aws_s3_bucket.rcv.arn}/*",
          aws_s3_bucket.rcv.arn,
        ]
        "Condition" = {
          "Bool" = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        "Sid"       = "EnforceProtoVer"
        "Effect"    = "Deny"
        "Principal" = "*"
        "Action"    = "s3:*"
        "Resource" = [
          "${aws_s3_bucket.rcv.arn}/*",
          aws_s3_bucket.rcv.arn
        ]
        "Condition" = {
          "NumericLessThan" = {
            "s3:TlsVersion" : 1.2
          }
        }
      }
    ]
  })
}

# cors configuration
resource "aws_s3_bucket_cors_configuration" "rcv" {
  bucket = aws_s3_bucket.rcv.id

  cors_rule {
    allowed_headers = ["Authorization", "Range"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "rcv" {
  bucket = aws_s3_bucket.rcv.id

  rule {
    id     = "remove_files"
    status = "Enabled"

    expiration {
      days = 1
    }
  }
}
