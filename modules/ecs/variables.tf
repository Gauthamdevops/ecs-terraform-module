variable "project_name" {
  description = "Name of the project used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for CloudWatch logs and ECS resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ECS security group will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security Group ID of the ALB to allow ingress into ECS tasks"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log group retention period in days"
  type        = number
  default     = 30
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the ECS Cluster"
  type        = bool
  default     = true
}

# ==========================================
# Frontend Service Variables
# ==========================================
variable "create_frontend_service" {
  description = "Whether to create the Frontend ECS task definition and service"
  type        = bool
  default     = false
}

variable "frontend_target_group_arn" {
  description = "ARN of the ALB target group for the frontend service"
  type        = string
  default     = ""
}

variable "frontend_container_image" {
  description = "Docker image repository and tag for the frontend task"
  type        = string
  default     = ""
}

variable "frontend_container_cpu" {
  description = "CPU units allocated to the frontend container (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "frontend_container_memory" {
  description = "Memory (in MiB) allocated to the frontend container"
  type        = number
  default     = 512
}

variable "frontend_desired_count" {
  description = "Number of instances of the frontend task definition to keep running"
  type        = number
  default     = 1
}

variable "frontend_app_port" {
  description = "Port the frontend container application listens on"
  type        = number
  default     = 80
}

variable "frontend_environment_variables" {
  description = "Environment variables to pass to the frontend container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "frontend_secrets" {
  description = "Secrets from AWS Secrets Manager or SSM Parameter Store for frontend container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# ==========================================
# Backend (API) Service Variables
# ==========================================
variable "create_backend_service" {
  description = "Whether to create the Backend ECS task definition and service"
  type        = bool
  default     = false
}

variable "backend_target_group_arn" {
  description = "ARN of the ALB target group for the backend API service"
  type        = string
  default     = ""
}

variable "backend_container_image" {
  description = "Docker image repository and tag for the backend API task"
  type        = string
  default     = ""
}

variable "backend_container_cpu" {
  description = "CPU units allocated to the backend container (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "backend_container_memory" {
  description = "Memory (in MiB) allocated to the backend container"
  type        = number
  default     = 512
}

variable "backend_desired_count" {
  description = "Number of instances of the backend task definition to keep running"
  type        = number
  default     = 1
}

variable "backend_app_port" {
  description = "Port the backend API container application listens on"
  type        = number
  default     = 8000
}

variable "backend_environment_variables" {
  description = "Environment variables to pass to the backend container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "backend_secrets" {
  description = "Secrets from AWS Secrets Manager or SSM Parameter Store for backend container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "tags" {
  description = "Additional tags to apply to ECS resources"
  type        = map(string)
  default     = {}
}
