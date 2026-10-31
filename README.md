# Terraform AWS ECS Fargate Infrastructure (Dev & Prod)

Modular, production-ready Terraform setup to provision an **Application Load Balancer (ALB)** with path-based routing, **Amazon ECS on AWS Fargate** running both **Frontend** and **Backend (API)** services in a **single shared ECS cluster**, and a fully segmented **Virtual Private Cloud (VPC)** across **Dev** and **Prod** environments.

---

## 🏛 Architecture Overview

```mermaid
graph TD
    Client([Internet Traffic]) -->|Port 80| ALB[Application Load Balancer\nPublic Subnets]
    
    ALB -->|Default Rule '/*'\nPort 80| FE_TG[Frontend Target Group]
    ALB -->|Path Rule '/api/*'\nPort 8000| BE_TG[Backend Target Group]

    subgraph VPC ["AWS VPC (Isolated Network)"]
        subgraph PublicSubnets ["Public Subnets"]
            ALB
            NAT[NAT Gateway Dev: 1 | Prod: 3 Multi-AZ]
            IGW[Internet Gateway]
        end
        
        subgraph PrivateSubnets ["Private Subnets"]
            subgraph ECSCluster ["Single Shared ECS Cluster"]
                FEService["Frontend ECS Service\n(Task Def: Frontend)"]
                BEService["Backend API ECS Service\n(Task Def: Backend)"]
            end
            CWLogs["CloudWatch Log Group\n/ecs/{project}-{env}"]
        end
    end
    
    FE_TG --> FEService
    BE_TG --> BEService
    FEService -->|Outbound pulls & updates| NAT
    BEService -->|Outbound pulls & updates| NAT
    NAT --> IGW
    FEService -.->|Push logs: stream 'frontend'| CWLogs
    BEService -.->|Push logs: stream 'backend'| CWLogs
```

### Security & Architecture Highlights
- **Single ECS Cluster**: Both Frontend and Backend services run within the same cluster to eliminate redundant infrastructure costs.
- **Pure HCL Task Definitions**: Task definitions are defined natively in Terraform using `jsonencode`, keeping the entire configuration inside Terraform without requiring external template files.
- **Independent Task Definitions & Services**: Frontend and Backend scale independently, have separate CPU/memory allocations, and can be deployed separately in CI/CD without causing downtime for each other.
- **Path-Based ALB Routing**:
  - `/*` (default) routes to the **Frontend** Target Group (e.g., port `80`).
  - `/api/*` routes to the **Backend (API)** Target Group (e.g., port `8000`).
- **Zero Public Exposure for Containers**: All ECS tasks run strictly within **Private Subnets** with no public IP addresses assigned.
- **Least-Privilege Security Group Chaining**: The ECS Security Group dynamically allows inbound traffic from the ALB security group on container ports (`80` and `8000`), blocking direct internet access.
- **Cost-Optimized Dev**: Dev uses **1 shared NAT Gateway** (~$32/mo savings per extra AZ).
- **High-Availability Prod**: Prod uses **3 Availability Zones** with **1 dedicated NAT Gateway per AZ** and multiple redundant tasks (`desired_count = 2+`) across AZs.

---

## 📁 Repository Structure

```
.
├── environments/
│   ├── dev/
│   │   ├── main.tf            # Dev root module wiring
│   │   ├── variables.tf       # Configurable Dev variables (Frontend & Backend)
│   │   ├── outputs.tf         # Exported ALB URLs & service names
│   │   ├── terraform.tfvars   # Dev parameter values
│   │   └── versions.tf        # AWS provider & remote backend config
│   └── prod/
│       ├── main.tf            # Prod root module wiring
│       ├── variables.tf       # Configurable Prod variables (Frontend & Backend)
│       ├── outputs.tf         # Exported ALB URLs & service names
│       ├── terraform.tfvars   # Prod parameter values
│       └── versions.tf        # AWS provider & remote backend config
└── modules/
    ├── vpc/                   # VPC, Subnets, NAT Gateways, Route Tables
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── alb/                   # ALB, Security Groups, FE & BE Target Groups, Routing Rules
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecs/                   # Single ECS Cluster, Frontend & Backend Task Defs, Services, IAM
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## ⚙️ Environment Configurations

| Parameter | Dev (`environments/dev`) | Prod (`environments/prod`) |
| :--- | :--- | :--- |
| **VPC CIDR** | `10.0.0.0/16` | `10.1.0.0/16` |
| **Availability Zones** | 2 (`us-east-1a`, `us-east-1b`) | 3 (`us-east-1a`, `us-east-1b`, `us-east-1c`) |
| **NAT Gateways** | `1` (Shared) | `3` (1 per AZ for high availability) |
| **Frontend Tasks** | `1` task (`256 CPU` / `512 MiB`) | `2` tasks (`512 CPU` / `1024 MiB`) |
| **Backend API Tasks** | `1` task (`256 CPU` / `512 MiB`) | `2` tasks (`512 CPU` / `1024 MiB`) |
| **ALB Routing** | `/*` -> Frontend, `/api/*` -> Backend | `/*` -> Frontend, `/api/*` -> Backend |
| **ALB Deletion Protection** | `false` | `true` |
| **CloudWatch Log Retention**| `7 days` | `90 days` |

---

## 🚀 Deployment Instructions

### Prerequisites
1. [Terraform CLI](https://developer.hashicorp.com/terraform/install) `>= 1.5.0` installed.
2. [AWS CLI](https://aws.amazon.com/cli/) installed and configured (`aws configure`).

---

## 🛠 Deployment Workflow (2 Phases)

### Phase 1: Deploy Core Infrastructure (VPC, ALB, Cluster, IAM)
By default, `create_frontend_service = false` and `create_backend_service = false` in `terraform.tfvars`. This provisions:
- VPC, Subnets, NAT Gateways, Route Tables
- ALB, Frontend Target Group, Backend Target Group, and Path Routing Rules
- ECS Cluster, CloudWatch Log Group, IAM Execution & Task Roles, Security Groups
*(No ECS Task Definitions or Services are launched yet until images exist).*

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

Outputs will provide your endpoints:
```text
frontend_url    = "http://my-app-dev-alb-123456789.us-east-1.elb.amazonaws.com"
backend_api_url = "http://my-app-dev-alb-123456789.us-east-1.elb.amazonaws.com/api"
```

---

### Phase 2: Deploy Container Workloads (Once Images are in ECR)
Once your Docker images are pushed to AWS ECR, update `terraform.tfvars`:

```hcl
# Enable Frontend
create_frontend_service  = true
frontend_container_image = "<account_id>.dkr.ecr.us-east-1.amazonaws.com/my-frontend:v1.0.0"
frontend_app_port        = 80

# Enable Backend
create_backend_service  = true
backend_container_image = "<account_id>.dkr.ecr.us-east-1.amazonaws.com/my-backend:v1.0.0"
backend_app_port        = 8000
```

Then re-run:
```bash
terraform apply
```

Terraform will register the **Frontend Task Definition**, **Backend Task Definition**, and spin up both **ECS Services** inside the single cluster, automatically registering them with their respective ALB target groups.

---

### Passing Environment Variables or Secrets
In `environments/{env}/main.tf`, you can pass environment variables or secrets to either service via the `ecs` module:
```hcl
module "ecs" {
  source = "../../modules/ecs"
  ...
  frontend_environment_variables = [
    { name = "NODE_ENV", value = "production" }
  ]

  backend_environment_variables = [
    { name = "DATABASE_HOST", value = "db.internal" },
    { name = "PORT",          value = "8000" }
  ]

  backend_secrets = [
    { name = "DB_PASSWORD", valueFrom = "arn:aws:ssm:us-east-1:123456789012:parameter/prod/db_pass" }
  ]
}
```

---

## 🧹 Cleanup / Teardown

To destroy the infrastructure:

```bash
# In Dev
cd environments/dev
terraform destroy

# In Prod (Note: set enable_deletion_protection = false first)
cd environments/prod
terraform destroy
```
