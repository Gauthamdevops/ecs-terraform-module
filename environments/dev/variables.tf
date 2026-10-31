variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "my-app"
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway across subnets for cost savings"
  type        = bool
  default     = true
}

# ==========================================
# Frontend Configuration
# ==========================================
variable "create_frontend_service" {
  description = "Whether to create Frontend task definition & service (set true once image is in ECR)"
  type        = bool
  default     = false
}

variable "frontend_container_image" {
  description = "Docker image repository URL and tag for frontend"
  type        = string
  default     = ""
}

variable "frontend_container_cpu" {
  description = "CPU units for frontend container (e.g. 256, 512, 1024)"
  type        = number
  default     = 256
}

variable "frontend_container_memory" {
  description = "Memory (in MiB) for frontend container (e.g. 512, 1024, 2048)"
  type        = number
  default     = 512
}

variable "frontend_desired_count" {
  description = "Desired number of running frontend task instances"
  type        = number
  default     = 1
}

variable "frontend_app_port" {
  description = "Port exposed by the frontend container application"
  type        = number
  default     = 80
}

variable "frontend_health_check_path" {
  description = "ALB target group health check path for frontend"
  type        = string
  default     = "/"
}

# ==========================================
# Backend (API) Configuration
# ==========================================
variable "create_backend_service" {
  description = "Whether to create Backend task definition & service (set true once image is in ECR)"
  type        = bool
  default     = false
}

variable "backend_container_image" {
  description = "Docker image repository URL and tag for backend API"
  type        = string
  default     = ""
}

variable "backend_container_cpu" {
  description = "CPU units for backend container (e.g. 256, 512, 1024)"
  type        = number
  default     = 256
}

variable "backend_container_memory" {
  description = "Memory (in MiB) for backend container (e.g. 512, 1024, 2048)"
  type        = number
  default     = 512
}

variable "backend_desired_count" {
  description = "Desired number of running backend task instances"
  type        = number
  default     = 1
}

variable "backend_app_port" {
  description = "Port exposed by the backend API container application"
  type        = number
  default     = 8000
}

variable "backend_health_check_path" {
  description = "ALB target group health check path for backend API"
  type        = string
  default     = "/api/health"
}

variable "backend_path_patterns" {
  description = "ALB routing path patterns directed to the backend API"
  type        = list(string)
  default     = ["/api/*", "/api"]
}

# ==========================================
# Common Settings
# ==========================================
variable "log_retention_days" {
  description = "Days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
