resource "tls_private_key" "acme_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "main" {
  account_key_pem = tls_private_key.acme_private_key.private_key_pem
  email_address   = "hi@m7.rs"
}

resource "acme_certificate" "main" {
  account_key_pem = acme_registration.main.account_key_pem
  # Domínio apex
  common_name = aws_route53_zone.main.name
  # Todos os subdomínios
  subject_alternative_names = ["*.${aws_route53_zone.main.name}"]

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = aws_route53_zone.main.zone_id
    }
  }

  depends_on = [acme_registration.main, aws_route53_zone.main]
}
resource "aws_acm_certificate" "cloudfront" {
  lifecycle {
    create_before_destroy = true
  }
  certificate_body  = acme_certificate.main.certificate_pem
  private_key       = acme_certificate.main.private_key_pem
  certificate_chain = acme_certificate.main.issuer_pem
}
