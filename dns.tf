resource "aws_route53_record" "dns" {
  count   = var.hosted_zone_id != "" && var.service_fqdn != "" ? var.enable_load_balancer ? 1 : 0 : 0
  zone_id = var.hosted_zone_id
  name    = var.service_fqdn
  type    = "A"
  alias {
    name                   = var.use_cloudfront ? aws_cloudfront_distribution.distribution[0].domain_name : aws_lb.alb.0.dns_name
    evaluate_target_health = false
    zone_id                = var.use_cloudfront ? aws_cloudfront_distribution.distribution[0].hosted_zone_id : aws_lb.alb.0.zone_id
  }
  allow_overwrite = var.route53_allow_overwrite
}

resource "aws_route53_record" "dns_ipv6" {
  count   = var.ipv6 && var.hosted_zone_id != "" && var.service_fqdn != "" ? var.enable_load_balancer ? 1 : 0 : 0
  zone_id = var.hosted_zone_id
  name    = var.service_fqdn
  type    = "AAAA"
  alias {
    name                   = var.use_cloudfront ? aws_cloudfront_distribution.distribution[0].domain_name : aws_lb.alb.0.dns_name
    evaluate_target_health = false
    zone_id                = var.use_cloudfront ? aws_cloudfront_distribution.distribution[0].hosted_zone_id : aws_lb.alb.0.zone_id
  }
  allow_overwrite = var.route53_allow_overwrite
}
