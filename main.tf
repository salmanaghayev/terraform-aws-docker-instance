data "aws_ami" "amazonlinux-2023" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86-64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "tf-ec2" {
  ami                    = data.aws_ami.amazonlinux-2023.id
  instance_type          = var.instance_type
  count                  = var.num_of_instance
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  user_data              = templatefile("${abspath(path.module)}/userdata.sh", { myserver = var.server-name })
  tags = {
    Name = var.tag
  }
}

resource "aws_security_group" "tf-sec-gr" {
  name = "${var.tag}-tf-security-group"
  tags = {
    Name = var.tag
  }
  dynamic "ingress" {
    for_each = var.docker-instance-ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      #   ipv6_cidr_blocks = []
      #   prefix_list_ids  = []
      #   security_groups  = []
      self = false
    }
  }
  egress = [{
    description      = "for all outgoing traffics"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
}
