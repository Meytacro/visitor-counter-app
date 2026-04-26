variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "dockerhub_user" {
  type = string
}

variable "image_version" {
  type    = string
  default = "v1"
}

variable "redis_host" {
  description = "ElastiCache Redis endpoint"
  type        = string
}