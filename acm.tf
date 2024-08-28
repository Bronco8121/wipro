data "aws_route53_zone" "public" {
  name         = "declandev.com."
  private_zone = false
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "*.declandev.com"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_route53_record" "route53" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.public.zone_id
}

resource "aws_acm_certificate_validation" "cert-validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.route53: record.fqdn]
}

data "aws_acm_certificate" "cert_issued" {
    domain = "*..declandev.com"
    statuses = ["ISSUED"]
    types = ["AMAZON_ISSUED"]
    most_recent = true

}
