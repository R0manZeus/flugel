provider "aws" {
  region     = var.avail_zone
  access_key = var.access_key
  secret_key = var.secret_key

}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
}

module "myapp-subnet" {
  source                 = "./modules/subnet"
  az                     = var.az
  subnet_cidr_block      = var.subnet_cidr_block
  env_prefix             = var.env_prefix
  vpc_id                 = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

}

module "myapp-server" {
  source                 = "./modules/webserver"
  vpc_id                 = aws_vpc.myapp-vpc.id
  env_prefix             = var.env_prefix
  image_name             = var.image_name
  my_public_key_location = var.my_public_key_location
  instance_type          = var.instance_type
  subnet_id              = module.myapp-subnet.subnet.id
  az                     = var.az
  instance_count         = var.instance_count
}

resource "aws_elb" "elb" {
  name               = "my-elb"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }
  instances                   = [module.myapp-server.instance[1].id, module.myapp-server.instance[0].id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags = {
    Name = "flugel"
  }
}



