output "app_url" {
  description = "Public URL of the site"
  value       = local.use_domain ? "https://${local.app_fqdn}" : "http://${aws_lb.main.dns_name}"
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.app.arn
}

output "rds_endpoint" {
  value = aws_db_instance.main.address
}

output "db_secret_arn" {
  description = "Secrets Manager ARN holding the DB username/password"
  value       = aws_secretsmanager_secret.db.arn
}

output "route53_nameservers" {
  description = "route53 mode: nameservers set on the domain at Hostinger"
  value       = local.use_route53 ? aws_route53_zone.main[0].name_servers : []
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.app.name
}
