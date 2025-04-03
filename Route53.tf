resource "aws_route53_record" "web_app_dns" {
  zone_id = var.web_app_dns_zone_id
  name    = var.web_app_dns_name
  type    = "A"


  alias {
    name                   = aws_lb.webapp_loadbalancer.dns_name
    zone_id                = aws_lb.webapp_loadbalancer.zone_id
    evaluate_target_health = true
  }
}