variable "project_name" {
  description = "Name of the project used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB and Target Groups will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

# Frontend Target Group Variables
variable "frontend_app_port" {
  description = "Port the frontend container application listens on"
  type        = number
  default     = 80
}

variable "frontend_health_check_path" {
  description = "HTTP path for frontend health check requests"
  type        = string
  default     = "/"
}

# Backend Target Group Variables
variable "backend_app_port" {
  description = "Port the backend API container application listens on"
  type        = number
  default     = 8000
}

variable "backend_health_check_path" {
  description = "HTTP path for backend health check requests"
  type        = string
  default     = "/api/health"
}

variable "backend_path_patterns" {
  description = "URL path patterns routed to the backend target group"
  type        = list(string)
  default     = ["/api/*", "/api"]
}

# Health Check Tunings
variable "health_check_matcher" {
  description = "HTTP status response codes indicating a healthy target"
  type        = string
  default     = "200-399"
}

variable "health_check_interval" {
  description = "Approximate amount of time, in seconds, between health checks"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Amount of time, in seconds, during which no response means a failed health check"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive health checks successes required before considering target healthy"
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering target unhealthy"
  type        = number
  default     = 3
}

variable "deregistration_delay" {
  description = "Time to wait before deregistering a target (in seconds)"
  type        = number
  default     = 30
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to ALB resources"
  type        = map(string)
  default     = {}
}
