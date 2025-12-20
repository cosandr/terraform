resource "aws_iam_user" "minio" {
  name = "minio"
}

# terraform output -raw encrypted_secret | base64 -d | gpg -d -q
# Can also get it from Ceph dashboard or CLI
resource "aws_iam_access_key" "minio" {
  user    = aws_iam_user.minio.name
  pgp_key = local.pgp_key
}

resource "aws_iam_user_policy_attachment" "minio" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ])

  user       = aws_iam_user.minio.name
  policy_arn = each.value
}

resource "pass_password" "minio" {
  path     = "rgw/minio_access_key"
  password = aws_iam_access_key.minio.id
}

resource "terraform_data" "minio_secret_key" {
  input = aws_iam_access_key.minio.encrypted_secret

  provisioner "local-exec" {
    command = "echo ${self.input} | base64 -d | gpg -d -q | gopass insert -f rgw/minio_secret_key"
  }
}
