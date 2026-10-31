output "cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

# Frontend Service Outputs
output "frontend_service_id" {
  description = "The ID of the Frontend ECS service"
  value       = try(aws_ecs_service.frontend[0].id, null)
}

output "frontend_service_name" {
  description = "The name of the Frontend ECS service"
  value       = try(aws_ecs_service.frontend[0].name, null)
}

output "frontend_task_definition_arn" {
  description = "The ARN of the Frontend Task Definition"
  value       = try(aws_ecs_task_definition.frontend[0].arn, null)
}

# Backend Service Outputs
output "backend_service_id" {
  description = "The ID of the Backend ECS service"
  value       = try(aws_ecs_service.backend[0].id, null)
}

output "backend_service_name" {
  description = "The name of the Backend ECS service"
  value       = try(aws_ecs_service.backend[0].name, null)
}

output "backend_task_definition_arn" {
  description = "The ARN of the Backend Task Definition"
  value       = try(aws_ecs_task_definition.backend[0].arn, null)
}

# Common ECS Outputs
output "task_execution_role_arn" {
  description = "The ARN of the ECS Task Execution IAM Role"
  value       = aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "The ARN of the ECS Task IAM Role"
  value       = aws_iam_role.task.arn
}

output "ecs_security_group_id" {
  description = "The ID of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs.name
}
