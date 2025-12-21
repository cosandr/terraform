resource "aws_iam_user" "loki" {
  name = "loki"
}

# terraform output -raw encrypted_secret | base64 -d | gpg -d -q
# Can also get it from Ceph dashboard or CLI
resource "aws_iam_access_key" "loki" {
  user    = aws_iam_user.loki.name
  pgp_key = local.pgp_key
}

# https://grafana.com/docs/loki/latest/configure/storage/#aws-deployment-s3-single-store
data "aws_iam_policy_document" "loki_inline" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::loki",
      "arn:aws:s3:::loki/*",
    ]
  }
}

resource "aws_iam_user_policy" "loki" {
  name   = "S3"
  user   = aws_iam_user.loki.name
  policy = data.aws_iam_policy_document.loki_inline.json
}

resource "aws_s3_bucket" "loki" {
  bucket = "loki"
}

resource "aws_s3_bucket_versioning" "loki" {
  bucket = aws_s3_bucket.loki.id

  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.loki]
}

# Looks like destroying fails, must be removed from state
resource "aws_s3_bucket_lifecycle_configuration" "loki" {
  bucket = aws_s3_bucket.loki.id

  rule {
    id = "old-version-delete"

    expiration {
      days = 365 * 3
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }

    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.loki, aws_s3_bucket_versioning.loki]
}
