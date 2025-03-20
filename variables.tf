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
variable "custom_ami" {
  type    = string
  default = "ami-05d7113acaa75a418"
}

variable "key_pair" {
  type    = string
  default = "test.pem"

}
variable "ENV" {
  type    = string
  default = "prod"
}

variable "PORT" {
  type    = number
  default = 8080
}

variable "db_identifier" {
  type    = string
  default = "csye6225"
}

variable "db_engine" {
  type    = string
  default = "mysql"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}
variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "csye6225"
}

variable "db_username" {
  type    = string
  default = "csye6225"
}


