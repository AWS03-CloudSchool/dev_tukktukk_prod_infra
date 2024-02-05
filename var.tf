variable "aws_region" {
  type    = string
  description = "The AWS region to deploy resources into"
}

variable "tuktuk_env" {
  type    = string
  description = "Development Environment Settings Variables"
}

variable "tuktuk_dns" {
  type    = string
  description = "Domain Name Settings"
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

variable "s3_bucket_name" {
    type = string
    description = "s3 bucket name"
}

variable "grafana_sub_dns" {
    type = string
    description = "grafana sub domain"
}

# backend service secret
variable "be_access_key" {
  description = "The AWS access key"
  type        = string
}

variable "be_secret_key" {
  description = "The AWS secret key"
  type        = string
}

variable "be_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "be_database_url" {
  description = "The database URL"
  type        = string
}

variable "mysql_root_username" {
  description = "The MySQL root username"
  type        = string
}

variable "mysql_root_password" {
  description = "The MySQL root password"
  type        = string
}