variable "jenkins_vpc_cidr" {
  description   = "The cidr range of the Jenkins VPC"
  type          = string
  default       = "10.0.0.0/16"
}
