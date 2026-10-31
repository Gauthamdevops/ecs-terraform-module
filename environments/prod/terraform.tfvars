aws_region   = "us-east-1"
project_name = "my-app"
environment  = "prod"

# VPC Configuration
vpc_cidr            = "10.1.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
database_subnet_cidrs = ["10.1.15.0/24", "10.1.16.0/24", "10.1.17.0/24"]
# High Availability: 1 NAT Gateway per AZ in Prod
single_nat_gateway = false

# Frontend Workload Configuration

create_frontend_service  = false # Set to true once frontend image is in ECR
frontend_container_image = ""    # e.g. <account_id>.dkr.ecr.us-east-1.amazonaws.com/my-frontend:v1.0.0
frontend_container_cpu   = 512   # 0.5 vCPU
frontend_container_memory = 1024 # 1024 MiB
frontend_desired_count   = 2     # Multi-AZ redundancy
frontend_app_port        = 80
frontend_health_check_path = "/"


# Backend (API) Workload Configuration

create_backend_service  = false  # Set to true once backend image is in ECR
backend_container_image = ""     # e.g. <account_id>.dkr.ecr.us-east-1.amazonaws.com/my-backend:v1.0.0
backend_container_cpu   = 512    # 0.5 vCPU
backend_container_memory = 1024  # 1024 MiB
backend_desired_count   = 2     # Multi-AZ redundancy
backend_app_port        = 8000
backend_health_check_path = "/api/health"
backend_path_patterns   = ["/api/*", "/api"]

# CloudWatch Logs & ALB Deletion Protection

log_retention_days         = 90
enable_deletion_protection = true

tags = {
  Environment = "prod"
  Project     = "my-app"
  aws-apn-id  = "pc:ci8u5fycyacwufkqe1sdeohql"
}
