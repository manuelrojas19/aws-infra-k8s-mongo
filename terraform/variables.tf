# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  default     = "bank"
}

variable "environment" {
  description = "Environment (e.g., dev, prod)"
  default     = "qa"
}

variable "ami" {
  description = "AMI"
  default     = "ami-0fe630eb857a6ec83"
}

variable "mongo_instance_type" {
  description = "Instance type"
  default     = "t2.medium"
}

variable "bastion_instance_type" {
  description = "Instance type"
  default     = "t2.micro"
}

variable "mongo_user" {
  description = "Mongo user"
  default     = "admin"
}

variable "mongo_password" {
  description = "Mongo password"
  default     = "password"
}

variable "cert_s3_bucket" {
  description = "Mongo S3 bucket"
  default     = "manulerojas19-terraform-mongo-bucket"
}
