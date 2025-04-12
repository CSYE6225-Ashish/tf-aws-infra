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

variable "db_password" {
  type    = string
  default = "Admin#8060"
}
#Assignment 7 changes
variable "webapp_application_autoscaling_group_min_size" {
  type    = number
  default = 1
}

variable "webapp_application_autoscaling_group_max_size" {
  type    = number
  default = 3
}

variable "webapp_application_autoscaling_group_desired_capacity" {
  type    = number
  default = 1
}


variable "webapp_application_autoscaling_group_health_check_grace_period" {
  type    = number
  default = 100
}

variable "scale_up_scaling_adjustment" {
  type    = number
  default = 1
}

variable "scale_up_cooldown" {
  type    = number
  default = 120
}

variable "scale_down_cooldown" {
  type    = number
  default = 120
}

variable "scale_down_scaling_adjustment" {
  type    = number
  default = -1
}

variable "cpu_high_evaluation_periods" {
  type    = number
  default = 2
}

variable "cpu_high_period" {
  type    = number
  default = 60
}

variable "cpu_high_threshold" {
  type    = number
  default = 10
}

variable "cpu_low_evaluation_periods" {
  type    = number
  default = 2
}

variable "cpu_low_period" {
  type    = number
  default = 60
}

variable "cpu_low_threshold" {
  type    = number
  default = 10
}

variable "health_check_healthy_threshold" {
  type    = number
  default = 3
}

variable "health_check_unhealthy_threshold" {
  type    = number
  default = 5
}

variable "health_check_interval" {
  type    = number
  default = 30
}

variable "health_check_timeout" {
  type    = number
  default = 10
}

variable "web_app_dns_zone_id" {
  type    = string
  default = "Z0820724QT2S4OL9OWJN"
}

variable "web_app_dns_name" {
  type    = string
  default = "demo.ashishgangaramani.me"
}

variable "web_app_dns_ttl" {
  type    = number
  default = 60
}

variable "kms_rotation_window" {
  type    = number
  default = 90
}

variable "kms_deletion_window" {
  type    = number
  default = 10
}

variable "certificate_arn" {
  type    = string
  default = "arn:aws:acm:us-east-1:343218179908:certificate/dadab474-01d8-4622-b265-c78598660616"
}