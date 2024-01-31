terraform {
  required_providers {
    aws ={
        source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "prod-s3-bucket-tfstate-aws03"
    key = "terraform/terraform.tfstate"
    region = "ap-northeast-2"
    dynamodb_table = "prod-terraform-tfstate-lock"
  }
}

provider "aws" {
    region = var.aws_region
    access_key = var.iam_private_key
    secret_key = var.iam_secret_key
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  host                   = aws_eks_cluster.dev_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.dev_cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.dev_cluster.token
}

# 기본 구성 설정
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.dev_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.dev_cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.dev_cluster.token
  }
}