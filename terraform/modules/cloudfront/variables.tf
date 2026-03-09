variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "origin_domain_name" {
  type        = string
  description = "ALB DNS name"
}
