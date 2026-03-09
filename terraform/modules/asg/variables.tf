variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.nano"
}

variable "min_size" {
  type        = number
  description = "Minimum number of instances"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances"
  default     = 2
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances"
  default     = 2
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ASG"
}

variable "security_group_id" {
  type = string
}

variable "user_data_path" {
  type = string
}

variable "target_group_arns" {
  type        = list(string)
  description = "List of target group ARNs"
  default     = []
}
