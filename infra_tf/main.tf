
# Latest Ubunutu LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
}

# RSA key of size 4096 bits
resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


// Dump the private key to a local file
resource "local_file" "jenkins_private_key" {
  content  = tls_private_key.jenkins_key.private_key_pem
  filename = "${path.cwd}/jenkins_key.pem"
  file_permission = "0400"
}

// Create a VPC for Jenkins
resource "aws_vpc" "jenkins" {
    enable_dns_hostnames = true
    cidr_block = var.jenkins_vpc_cidr
    tags = {
        Name = "jenkins-vpc"
    }
}

// Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "jenkins_igw" {
    vpc_id = aws_vpc.jenkins.id
    tags = {
        Name = "jenkins-igw"
    }
}

// Create a public subnet in the VPC
resource "aws_subnet" "jenkins_public_subnet" {
    map_public_ip_on_launch = true
    vpc_id            = aws_vpc.jenkins.id
    cidr_block        = "10.0.0.0/24"
    availability_zone = "eu-central-1a"
    tags = {
        Name = "jenkins-public-subnet"
    }
}

// Create a route table for the public subnet
resource "aws_route_table" "jenkins_public_rt" {
    vpc_id = aws_vpc.jenkins.id
    tags = {
        Name = "jenkins-public-rt"
    }
}

// Attach a route to the Internet Gateway
resource "aws_route" "jenkins_public_route" {
    route_table_id         = aws_route_table.jenkins_public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.jenkins_igw.id
}

// Attach a route to the public subnet
resource "aws_route_table_association" "jenkins_public_rt_assoc" {
    subnet_id      = aws_subnet.jenkins_public_subnet.id
    route_table_id = aws_route_table.jenkins_public_rt.id
}

// Create a key pair for SSH access
resource "aws_key_pair" "jenkins_key_pair" {
  key_name   = "jenkins-key"
  public_key = tls_private_key.jenkins_key.public_key_openssh
}

// Create a SSH security group
resource "aws_security_group" "jenkins_ssh_sg" {
    name        = "jenkins-ssh-sg"
    description = "Allow SSH inbound traffic"
    vpc_id      = aws_vpc.jenkins.id
    ingress {
        from_port   = 22
        to_port     = 22
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
        Name = "jenkins-ssh-sg"
    }
}

// Create a 8080 security group
resource "aws_security_group" "jenkins_ee_sg" {
    name        = "jenkins-port-sg"
    description = "Allow traffic on the jenkins port"
    vpc_id      = aws_vpc.jenkins.id
    ingress {
        from_port   = 8080
        to_port     = 8080
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
        Name = "jenkins-port-sg"
    }
}

// Create an HTTP security group
resource "aws_security_group" "jenkins_http_sg" {
    name        = "http-sg"
    description = "Allow http inbound traffic"
    vpc_id      = aws_vpc.jenkins.id
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
        Name = "jenkins-http-sg"
    }
}

// Create a Jenkins EC2 instance
resource "aws_instance" "jenkins_server" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.jenkins_public_subnet.id
    key_name               = aws_key_pair.jenkins_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.jenkins_ssh_sg.id, aws_security_group.jenkins_ee_sg.id, aws_security_group.jenkins_http_sg.id]
    tags = {
        Name = "jenkins-server"
    }
}

# // Create a Jenkins agent EC2 instance
# resource "aws_instance" "jenkins_agent" {
#     ami                    = data.aws_ami.ubuntu.id
#     instance_type          = "t2.micro"
#     subnet_id              = aws_subnet.jenkins_public_subnet.id
#     key_name               = aws_key_pair.jenkins_key_pair.key_name
#     vpc_security_group_ids = [aws_security_group.jenkins_ssh_sg.id, aws_security_group.jenkins_ee_sg.id, aws_security_group.jenkins_http_sg.id]
#     tags = {
#         Name = "jenkins-agent"
#     }
# }

// Output the public IP of the Jenkins server
output "jenkins_server_public_ip" {
    description = "The public IP of the Jenkins server"
    value       = aws_instance.jenkins_server.public_ip
}

// Dump the public IP to an ansible inventory file located at ../ansible/inventory/jenkins_server.ini
resource "local_file" "jenkins_inventory" {
  content  =  <<-EOT
  [jenkins_server] 
  ${aws_instance.jenkins_server.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.cwd}/jenkins_key.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  EOT
  filename = "${path.module}./ansible/inventory/jenkins_server.ini"
}
#   [jenkins_agent]
#   ${aws_instance.jenkins_agent.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.cwd}/jenkins_key.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
