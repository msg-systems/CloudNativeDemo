output "service_link" {
  value = "http://${aws_lb.alb.dns_name}"
}

output "git_repository" {
  value = aws_codecommit_repository.this.clone_url_http
}
