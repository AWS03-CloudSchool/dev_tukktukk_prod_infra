aws_region           = "ap-northeast-2"
vpc_cidr             = "192.168.0.0/16"
public_subnet_cidrs  = ["192.168.1.0/24", "192.168.2.0/24"]
private_subnet_cidrs =  ["192.168.3.0/24", "192.168.4.0/24"]
infra_name           = "tukktukk-prod-infra"
azs                  = ["ap-northeast-2a", "ap-northeast-2b"]

# 저장소 이름
s3_bucket_name       = "prod-tukktukk-logs-storage"

# 도메인
argocd_sub_dns       = "prod-argocd"
grafana_sub_dns      = "prod-grafana"
tuktuk_dns           = "tukktukk"
tuktuk_env           = "prod"