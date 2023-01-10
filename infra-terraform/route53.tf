resource "aws_route53_zone" "main" {
  name              = var.domain
  delegation_set_id = var.delegation_set
}

resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain
  # Não pode ser ALIAS pois é apex da zona
  type = "A"
  # ALIAS "simulado" da AWS
  alias {
    # Apontar para o cloudfront
    name    = aws_cloudfront_distribution.calculator.domain_name
    zone_id = aws_cloudfront_distribution.calculator.hosted_zone_id
    # Não estamos fazendo nada distribuido ou com fallback, então não precisa
    evaluate_target_health = false
  }
}
