resource "aws_iam_user" "barman" {
  name = "barman"
}

# terraform output -raw encrypted_secret | base64 -d | gpg -d -q
# Can also get it from Ceph dashboard or CLI
resource "aws_iam_access_key" "barman" {
  user    = aws_iam_user.barman.name
  pgp_key = local.pgp_key
}

data "aws_iam_policy_document" "barman_inline" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::cnpg-backups",
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::cnpg-backups/*",
    ]
  }
}

resource "aws_iam_user_policy" "barman" {
  name   = "S3"
  user   = aws_iam_user.barman.name
  policy = data.aws_iam_policy_document.barman_inline.json
}

resource "aws_s3_bucket" "barman" {
  bucket = "cnpg-backups"
}

resource "aws_s3_bucket_versioning" "barman" {
  bucket = aws_s3_bucket.barman.id

  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.barman]
}

# Looks like destroying fails, must be removed from state
resource "aws_s3_bucket_lifecycle_configuration" "barman" {
  bucket = aws_s3_bucket.barman.id

  rule {
    id = "old-version-delete"

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }

    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.barman, aws_s3_bucket_versioning.barman]
}
