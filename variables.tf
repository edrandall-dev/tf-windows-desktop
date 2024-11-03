variable "region" {
  description = "The AWS region in which the neo4j instances will be deployed"
}

variable "base_cidr_block" {
  description = "The base CIDR range for the VPC"
}

variable "creator" {
  description = "A variable containing details of the environment's creator"
}

variable "env_prefix" {
  description = "A variable containting a prefix for other variables"
}

variable "instance_type" {
  description = "A variable containing the desired instance type"
}

variable "public_key_path" {
  description = "The location of the SSH key within the local environment"
}

variable "private_key_path" {
  description = "The location of the SSH key within the local environment"
}

locals {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}