variable "profile" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-west-1"
}

variable "vpc" {
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "MainVPC"
    cidr = "10.0.0.0/16"
  }

 
}
 variable "custom_ami"{
    type = string
    default = "ami-05d7113acaa75a418"
  }

variable "key_pair" {
  type = string
  default = "test.pem"
  
}