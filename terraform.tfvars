aws_region = "ap-northeast-2"
vpc_cidr = "192.168.0.0/16"
public_subnet_cidrs = ["192.168.1.0/24", "192.168.2.0/24"]
private_subnet_cidrs =  ["192.168.3.0/24", "192.168.4.0/24"]
infra_name = "tukktukk-prod-infra"
azs = ["ap-northeast-2a", "ap-northeast-2b"]

# 저장소 이름
s3_bucket_name_log = "prod-tukktukk-logs-storage"
s3_bucket_name_tfstate = "prod-s3-bucket-tfstate-aws03"
dynamodb_bucket_name_tfstate = "prod-terraform-tfstate-lock"

# 도메인
argocd_sub_dns = "prod-argocd"
grafana_sub_dns = "prod-grafana"
app_sub_dns = "prod"