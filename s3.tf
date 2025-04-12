resource "random_uuid" "bucket_name" {}

resource "aws_s3_bucket" "private_bucket" {
  bucket = random_uuid.bucket_name.result

  force_destroy = true

  tags = {
    Name        = "Private S3 Bucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_policy" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    id     = "TransitionToStandardIA"
    status = "Enabled"

    filter {
      prefix = "" # Applies to all objects in the bucket
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}