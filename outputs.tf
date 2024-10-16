output "task_definition" {
  value = aws_ecs_task_definition.fargate
}
output "service" {
  value = aws_ecs_service.fargate
}
output "task_role" {
  value = aws_iam_role.ecs_task
}
output "task_execution_role" {
  value = aws_iam_role.ecs_execution
}
output "alb_dns" {
  value = try(aws_lb.alb.0.dns_name, null)
}
output "alb" {
  value = try(aws_lb.alb.0, null)
}
output "security_group_id" {
  value = aws_security_group.fargate.id
}
output "cloudfront" {
  value = try(aws_cloudfront_distribution.distribution[0], null)
}
