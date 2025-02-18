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