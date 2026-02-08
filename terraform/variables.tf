variable "service" {
  description = "Service name for ECS cluster"
  type        = string
  default     = "hello-service"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 5000
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container in MB"
  type        = number
  default     = 512
}

# ECS Service configuration
variable "desired_count" {
  description = "Number of task replicas to run"
  type        = number
  default     = 2
}
