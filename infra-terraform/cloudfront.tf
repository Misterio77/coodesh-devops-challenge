# Distribuir pelo cloudfront
# Precisamos disso para ter HTTPS (o s3 websites não tem)
resource "aws_cloudfront_distribution" "calculator" {
  origin {
    domain_name = aws_s3_bucket.calculator.bucket_regional_domain_name
    origin_id   = "calculatorS3"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [var.domain]
  price_class         = "PriceClass_100" # TODO parametrizar

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = "calculatorS3"
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cloudfront.arn
    ssl_support_method  = "sni-only"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}
