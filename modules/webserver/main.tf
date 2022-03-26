resource "aws_default_security_group" "myapp-sg" {
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "my-app security group from terraform"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "my-app security group from terraform"
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
  }


  egress {
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "myapp eggress security group for terraform"
    from_port       = 0
    prefix_list_ids = []
    protocol        = "-1"
    to_port         = 0
  }
  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

// querying the latest amazon linux 2 ami
data "aws_ami" "latest_amazon_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [var.image_name]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_key_pair" "ssh-key" {
  key_name   = "myapp-key"
  public_key = file(var.my_public_key_location)
}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.latest_amazon_ami.id
  instance_type = var.instance_type

  // creating the instance inside our subnet and using my security-group
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.myapp-sg.id]

  key_name                    = aws_key_pair.ssh-key.key_name
  availability_zone           = var.az
  associate_public_ip_address = true
  user_data                   = file("entry-script.sh")
  count                       = var.instance_count
  tags = {
    Name = "Flugel"
  }
}


