resource "aws_iam_user" "talos" {
  name = "talos"
}

# terraform output -raw encrypted_secret | base64 -d | gpg -d -q
# Can also get it from Ceph dashboard or CLI
resource "aws_iam_access_key" "talos" {
  user    = aws_iam_user.talos.name
  pgp_key = local.pgp_key
}

data "aws_iam_policy_document" "talos_inline" {
  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::talos-backups/*",
    ]
  }
}

resource "aws_iam_user_policy" "talos" {
  name   = "S3"
  user   = aws_iam_user.talos.name
  policy = data.aws_iam_policy_document.talos_inline.json
}

resource "aws_s3_bucket" "talos" {
  bucket = "talos-backups"
}

resource "aws_s3_bucket_versioning" "talos" {
  bucket = aws_s3_bucket.talos.id

  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.talos]
}

# Looks like destroying fails, must be removed from state
resource "aws_s3_bucket_lifecycle_configuration" "talos" {
  bucket = aws_s3_bucket.talos.id

  rule {
    id = "old-version-delete"

    expiration {
      days = 180
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }

    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.talos, aws_s3_bucket_versioning.talos]
}
