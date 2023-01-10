output "s3_name" {
  description = "Nome do Bucket. Útil para deploy."
  value       = aws_s3_bucket.calculator.bucket
}
output "cf_id" {
  description = "ID da distribution. Útil para deploy."
  value       = aws_cloudfront_distribution.calculator.id
}
