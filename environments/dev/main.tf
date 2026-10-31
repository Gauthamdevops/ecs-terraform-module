provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.tags,
      {
        Project     = var.project_name
        Environment = var.environment
        ManagedBy   = "Terraform"
      }
    )
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name          = var.project_name
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  single_nat_gateway    = var.single_nat_gateway
  tags                  = var.tags
}

# Application Load Balancer Module (Frontend TG, Backend TG, and Path Routing)
module "alb" {
  source = "../../modules/alb"

  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  public_subnet_ids          = module.vpc.public_subnet_ids
  frontend_app_port          = var.frontend_app_port
  frontend_health_check_path = var.frontend_health_check_path
  backend_app_port           = var.backend_app_port
  backend_health_check_path  = var.backend_health_check_path
  backend_path_patterns      = var.backend_path_patterns
  enable_deletion_protection = false
  tags                       = var.tags
}

# ECS Cluster & Services Module (Single Cluster, Independent Frontend & Backend Services)
module "ecs" {
  source = "../../modules/ecs"

  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  log_retention_days    = var.log_retention_days
  tags                  = var.tags

  # Frontend Configuration
  create_frontend_service   = var.create_frontend_service
  frontend_target_group_arn = module.alb.frontend_target_group_arn
  frontend_container_image  = var.frontend_container_image
  frontend_container_cpu    = var.frontend_container_cpu
  frontend_container_memory = var.frontend_container_memory
  frontend_desired_count    = var.frontend_desired_count
  frontend_app_port         = var.frontend_app_port

  # Backend (API) Configuration
  create_backend_service   = var.create_backend_service
  backend_target_group_arn = module.alb.backend_target_group_arn
  backend_container_image  = var.backend_container_image
  backend_container_cpu    = var.backend_container_cpu
  backend_container_memory = var.backend_container_memory
  backend_desired_count    = var.backend_desired_count
  backend_app_port         = var.backend_app_port
}
