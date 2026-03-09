project        = "global360"
environment    = "dev"
vpc_cidr_block = "172.16.0.0/16"
public_subnets = [
  {
    cidr_block        = "172.16.1.0/24"
    availability_zone = "ap-southeast-2a"
  },
  {
    cidr_block        = "172.16.2.0/24"
    availability_zone = "ap-southeast-2b"
  }
]
private_subnets = [
  {
    cidr_block        = "172.16.11.0/24"
    availability_zone = "ap-southeast-2a"
  },
  {
    cidr_block        = "172.16.12.0/24"
    availability_zone = "ap-southeast-2b"
  }
]
instances = [
  { name = "app-0", subnet_index = 0 },
  { name = "app-1", subnet_index = 1 }
]