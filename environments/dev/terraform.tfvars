aws_region   = "us-east-1"
project_name = "my-app"
environment  = "dev"

# VPC Configuration
vpc_cidr              = "10.0.0.0/16"
availability_zones    = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24"]
database_subnet_cidrs = ["10.0.12.0/24", "10.0.13.0/24"]

# Cost-optimized: 1 NAT Gateway for Dev
single_nat_gateway = true

# Frontend Workload Configuration
create_frontend_service    = false # Set to true once frontend image is in ECR
frontend_container_image   = ""    # e.g. <account_id>.dkr.ecr.us-east-1.amazonaws.com/my-frontend:latest
frontend_container_cpu     = 256   # 0.25 vCPU
frontend_container_memory  = 512   # 512 MiB
frontend_desired_count     = 1
frontend_app_port          = 80
frontend_health_check_path = "/"

# Backend (API) Workload Configuration
create_backend_service    = false # Set to true once backend image is in ECR
backend_container_image   = ""    # e.g. <account_id>.dkr.ecr.us-east-1.amazonaws.com/my-backend:latest
backend_container_cpu     = 256   # 0.25 vCPU
backend_container_memory  = 512   # 512 MiB
backend_desired_count     = 1
backend_app_port          = 8000
backend_health_check_path = "/api/health"
backend_path_patterns     = ["/api/*", "/api"]

# CloudWatch Logs
log_retention_days = 7

tags = {
  Environment = "dev"
  Project     = "my-app"
  aws-apn-id  = "pc:ci8u5fycyacwufkqe1sdeohql"
}
