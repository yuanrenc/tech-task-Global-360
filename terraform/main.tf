module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  public_subnets = var.public_subnets
  project        = var.project
  environment    = var.environment
}

module "compute" {
  source = "./modules/compute"

  instance_type = var.instance_type
  instances = [
    for instance in var.instances : {
      name      = instance.name
      subnet_id = module.vpc.subnet_ids[instance.subnet_index]
    }
  ]
  security_group_id = module.vpc.security_group_id
  user_data_path    = "${path.module}/user-data/ec2-init.sh"
  project           = var.project
  environment       = var.environment
}