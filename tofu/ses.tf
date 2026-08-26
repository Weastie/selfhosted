resource "aws_ses_domain_identity" "soulhatch" {
  domain = "soulhatch.band"
}

# Verification for SES identity
resource "namecheap_domain_host_record" "soulhatch_ses" {
  domain   = "soulhatch.band"
  hostname = "_amazonses"
  type     = "TXT"
  address  = aws_ses_domain_identity.soulhatch.verification_token
}

# Allows emails to appear as if they are from soulhatch.band
resource "aws_ses_domain_mail_from" "soulhatch" {
  domain           = aws_ses_domain_identity.soulhatch.domain
  mail_from_domain = "mail.soulhatch.band"
}


resource "namecheap_domain_records" "soulhatch" {
  domain = "soulhatch.band"
  email_type = "MX"
  mode = "MERGE"

  record {
    hostname = split(".", aws_ses_domain_mail_from.soulhatch.mail_from_domain)[0]
    type     = "MX"
    address  = "feedback-smtp.us-east-1.amazonses.com"
    mx_pref = 10
    ttl = 600
  }
}

resource "namecheap_domain_host_record" "soulhatch_mailfrom_txt" {
  domain   = "soulhatch.band"
  # This grabs just the subdomain from the mail_from_domain
  hostname = split(".", aws_ses_domain_mail_from.soulhatch.mail_from_domain)[0]
  type     = "TXT"
  address  = "v=spf1 include:amazonses.com ~all"
  ttl = 600
}

resource "aws_ses_domain_dkim" "soulhatch" {
  domain = aws_ses_domain_identity.soulhatch.domain
}

resource "namecheap_domain_host_record" "soulhatch_dkim" {
  count = 3
  domain   = "soulhatch.band"
  # This grabs just the subdomain from the mail_from_domain
  hostname    = "${aws_ses_domain_dkim.soulhatch.dkim_tokens[count.index]}._domainkey"
  type     = "CNAME"
  address  = "${aws_ses_domain_dkim.soulhatch.dkim_tokens[count.index]}.dkim.amazonses.com"
  ttl = 600
}

# Create IAM user for SMTP credentials
resource "aws_iam_user" "ses_smtp_user" {
  name = "ses-smtp-user"
}

resource "aws_iam_user_policy" "ses_smtp_policy" {
  name = "ses-smtp-policy"
  user = aws_iam_user.ses_smtp_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ses:SendRawEmail"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "ses_smtp_key" {
  user = aws_iam_user.ses_smtp_user.name
}

# Outputs (marked sensitive so credentials don't leak in CI/CD logs)
output "smtp_username" {
  value     = aws_iam_access_key.ses_smtp_key.id
  sensitive = true
}

output "smtp_password" {
  value     = aws_iam_access_key.ses_smtp_key.ses_smtp_password_v4
  sensitive = true
}
