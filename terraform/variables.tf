variable "jenkins_vpc_cidr" {
  description   = "The cidr range of the Jenkins VPC"
  type          = string
  default       = "10.0.0.0/16"
}

variable "ubuntu_ami" {
  description   = "The Ubuntu AMI ID"
  type          = string
  default       = "ami-004e960cde33f9146"
}
