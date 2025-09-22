variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name for SSH (create this in AWS console or set accordingly)"
}

variable "docker_image" {
  type    = string
  default = "devanshi2123/flask-app:latest"
}
