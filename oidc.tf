# OIDC Provider url
data "tls_certificate" "oidc_url" {
  url = aws_eks_cluster.dev_cluster.identity[0].oidc[0].issuer
  depends_on = [aws_eks_node_group.dev_node_group]
}

# 자격 증명 공급자 생성
# https://www.amazontrust.com/repository/ Root CA url
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = [ "sts.amazonaws.com" ]
  thumbprint_list = [data.tls_certificate.oidc_url.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.oidc_url.url

  depends_on = [ data.tls_certificate.oidc_url]
}

locals {
  oidc_provider_arn = aws_iam_openid_connect_provider.oidc_provider.arn
  oidc_provider = replace(local.oidc_provider_arn, "/^arn:aws:iam::[0-9]+:oidc-provider\\//", "")
}
