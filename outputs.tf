output "ec2-public-ip-1" {
  value = module.myapp-server.instance[0].public_ip
}

output "ec2-public-ip-2" {
  value = module.myapp-server.instance[1].public_ip
}
