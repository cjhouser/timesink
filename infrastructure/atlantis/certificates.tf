resource "aws_acm_certificate" "atlantis" {
  domain_name       = aws_route53_record.atlantis.name
  validation_method = "DNS"
  key_algorithm     = "RSA_2048"
  validation_option {
    domain_name       = aws_route53_record.atlantis.fqdn
    validation_domain = "thoughtlyify.io"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "atlantis_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.atlantis.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.thoughtlyifyio.zone_id
}

resource "aws_acm_certificate_validation" "atlantis" {
  certificate_arn         = aws_acm_certificate.atlantis.arn
  validation_record_fqdns = [for record in aws_route53_record.atlantis_cert_validation : record.fqdn]
}