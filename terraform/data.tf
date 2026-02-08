# Fetch the existing ecsTaskExecutionRole
data "aws_iam_role" "task_execution" {
  name = "ecsTaskExecutionRole"
}

# Use the existing VPC in the AWS account
data "aws_vpc" "main" {
  default = true
}

# Get public subnets (for ALB)
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# Get availability zones for the region
data "aws_availability_zones" "available" {
}
