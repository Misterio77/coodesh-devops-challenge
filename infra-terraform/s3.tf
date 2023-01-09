# O bucket propriamente dito
resource "aws_s3_bucket" "calculator" {
  # Eu gosto de usar o domínio como "namespace"
  bucket = replace(var.domain, ".", "-")
}

# Controle de acesso
resource "aws_s3_bucket_acl" "calculator" {
  bucket = aws_s3_bucket.calculator.id
  acl    = "public-read"
}
