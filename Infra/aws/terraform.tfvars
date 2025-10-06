aws_region     = "us-east-1"
project_name   = "nodejs-crud-ecs"

# Application and ECS Configuration
container_port = 3000
ecr_repo_name  = "nodejs-crud-repo"
task_cpu       = 512  # 512 is 0.5 vCPU
task_memory    = 1024 # 1024 MiB (1 GB)

# Database Configuration
db_username    = "dbadmin"