resource "aws_s3_bucket" "backup" {
  bucket = "weastie-selfhosted-backups"

}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "backup_user" {
  name = "backup-user"
}

resource "aws_iam_access_key" "backup_user" {
  user = aws_iam_user.backup_user.name
}

data "aws_iam_policy_document" "backup_user" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.backup.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.backup.arn}/*"]
  }
}

resource "aws_iam_user_policy" "backup_user" {
  name   = "backup-user"
  user   = aws_iam_user.backup_user.name
  policy = data.aws_iam_policy_document.backup_user.json
}

# 6. Output Credentials
output "backup_access_key_id" {
  value       = aws_iam_access_key.backup_user.id
  description = "The IAM Access Key ID"
}

output "backup_secret_access_key" {
  value       = aws_iam_access_key.backup_user.secret
  description = "The IAM Secret Access Key"
  sensitive   = true # Prevents secret key from printing directly in CLI stdout
}
