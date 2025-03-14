
resource "aws_instance" "docker" {
  ami                    = "ami-09c813fb71547fc4f" # This is our devops-practice AMI ID
  vpc_security_group_ids = [aws_security_group.allow_all_docker.id]
  instance_type          = "t3.micro"

  # 20GB is not enough
  root_block_device {
    volume_size = 50  # Set root volume size to 50GB
    volume_type = "gp3"  # Use gp3 for better performance (optional)
  }
  
  # user_data = file("docker.sh")
  tags = {
    Name    = "docker-tf"
  }
}
resource "null_resource" "docker" {
  # Changes to any instance of the instance requires re-provisioning
  triggers = {
    instance_id = aws_instance.docker.id
  }

   connection {
    host = aws_instance.docker.public_ip
    type = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "docker.sh"
    destination = "/home/ec2-user/docker.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with public_ip of each node in the cluster
    inline = [
      "chmod +x /home/ec2-user/docker.sh",
      "sudo sh /home/ec2-user/docker.sh "
    ]
  }
}

resource "aws_security_group" "allow_all_docker" {
  name        = "allow_all_docker"
  description = "Allow TLS inbound traffic and all outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
output "docker_ip" {
  value       = aws_instance.docker.public_ip
}
