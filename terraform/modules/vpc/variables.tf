variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for VPC"
}

variable "public_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "List of public subnets"
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}
