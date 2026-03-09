variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, prod)"
}

variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "vpc_cidr_block" {
  type = string
}

variable "public_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "List of public subnets with CIDR and AZ"
}

variable "private_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "List of private subnets with CIDR and AZ"
}

variable "instances" {
  type = list(object({
    name         = string
    subnet_index = number
  }))
  description = "List of instances to create"
}

variable "instance_type" {
  type    = string
  default = "t2.nano"
}

