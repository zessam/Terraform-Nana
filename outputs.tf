output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}

output "ec2_private_ip" {
  value = aws_instance.myapp-server.private_ip
}

output "ec2_instance_id" {
  value = aws_instance.myapp-server.id
}

