# spa/acm


provider "aws" {
  region = "us-east-1"
  alias = "acm_provider"
}

resource "aws_acm_certificate" "cert" {
  provider = aws.acm_provider
  domain_name               = "*.${var.hosted_zone}"
  subject_alternative_names = var.alt_domain_list
  validation_method         = "DNS"
  tags                      = {}
}

resource "aws_route53_record" "cert_validation" {
  provider = aws.acm_provider
  count = length(var.alt_domain_list) +1
  zone_id = var.route_53_primart_zone_id
  name    = element(aws_acm_certificate.cert.domain_validation_options.*.resource_record_name, count.index)
  type    = element(aws_acm_certificate.cert.domain_validation_options.*.resource_record_type, count.index)
  records = [element(aws_acm_certificate.cert.domain_validation_options.*.resource_record_value, count.index)]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  provider = aws.acm_provider

  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = aws_route53_record.cert_validation.*.fqdn
}




