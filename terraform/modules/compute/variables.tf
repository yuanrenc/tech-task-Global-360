variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "instances" {
  type = list(object({
    name      = string
    subnet_id = string
  }))
  description = "List of instances to create"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID"
}

variable "user_data_path" {
  type        = string
  description = "Path to user data script"
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}
