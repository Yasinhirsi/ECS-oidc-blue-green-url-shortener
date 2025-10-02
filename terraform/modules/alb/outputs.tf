output "alb_arn" {
  description = "Application Load Balancer ARN"
  value       = aws_lb.url_alb.arn
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.url_alb.dns_name
}

output "blue_tg_arn" {
  description = "Blue target group ARN"
  value       = aws_lb_target_group.blue_tg.arn
}

output "green_tg_arn" {
  description = "Green target group ARN"
  value       = aws_lb_target_group.green_tg.arn
}

output "http_listener_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}

output "waf_acl_arn" {
  description = "WAFv2 Web ACL ARN"
  value       = aws_wafv2_web_acl.url-shortener-waf.arn
}


