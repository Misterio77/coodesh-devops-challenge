output "s3_bucket_name" {
  description = "ID da distribution. Útil para deploy."
  value       = aws_s3_bucket.calculator.bucket
}
output "cloudfront_distribution_id" {
  description = "ID da distribution. Útil para deploy."
  value       = aws_cloudfront_distribution.calculator.id
}
