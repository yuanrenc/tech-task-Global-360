//Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "app" {
  count = length(var.instances)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.instances[count.index].subnet_id
  vpc_security_group_ids = [var.security_group_id]
  user_data              = file(var.user_data_path)

  tags = { Name = "${var.project}-${var.environment}-${var.instances[count.index].name}" }
}

resource "aws_eip" "app_eip" {
  count = length(var.instances)

  instance = aws_instance.app[count.index].id
  tags     = { Name = "${var.project}-${var.environment}-eip-${var.instances[count.index].name}" }
}
