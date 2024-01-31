variable "aws_region" {
  type    = string
  description = "The AWS region to deploy resources into"
}

variable "vpc_cidr" {
  type    = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  description = "List of CIDR blocks for the public subnets"
}

variable "private_subnet_cidrs" {
  type    = list(string)
  description = "List of CIDR blocks for the private subnets"
}

variable "iam_private_key" {
  type = string
  description = "Private key for Authentication."
}

variable "iam_secret_key" {
  type = string
  description = "Private key for Authentication."
}

variable "azs" {
  type    = list(string)
  description = "A list of availability zones in the region"
  default     = ["ap-northeast-2a", "ap-northeast-2b"]
}

variable "infra_name" {
  type = string
  description = "infra-name"
}

variable "argocd_sub_dns" {
    type = string
    description = "argocd sub domain"
}

variable "grafana_sub_dns" {
    type = string
    description = "grafana sub domain"
}

variable "app_sub_dns" {
    type = string
    description = "app sub domain"
}

variable "s3_bucket_name_log" {
    type = string
    description = "s3 bucket name for log"
}

variable "s3_bucket_name_tfstate" {
    type = string
    description = "s3 bucket name for tfstate"
}

variable "dynamodb_bucket_name_tfstate" {
    type = string
    description = "dynamoDB name for tfstate"
}