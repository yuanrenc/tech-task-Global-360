output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "alb_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.app.dns_name}"
}
