output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "database_subnets" {
  description = "List of database subnet IDs"
  value       = module.vpc.database_subnet_ids
}

output "nat_gateway_ips" {
  description = "Public IP addresses of NAT Gateways"
  value       = module.vpc.nat_gateway_ips
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "frontend_url" {
  description = "HTTP URL to access the Frontend via the ALB"
  value       = "http://${module.alb.alb_dns_name}"
}

output "backend_api_url" {
  description = "HTTP URL to access the Backend API via the ALB"
  value       = "http://${module.alb.alb_dns_name}/api"
}

output "ecs_cluster_name" {
  description = "Name of the single shared ECS Cluster"
  value       = module.ecs.cluster_name
}

output "frontend_service_name" {
  description = "Name of the Frontend ECS Service"
  value       = module.ecs.frontend_service_name
}

output "backend_service_name" {
  description = "Name of the Backend ECS Service"
  value       = module.ecs.backend_service_name
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group for application logs"
  value       = module.ecs.cloudwatch_log_group_name
}
