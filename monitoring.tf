# LOKI IAM Role을 위한 정책 생성
resource "aws_iam_policy" "loki_iam_policy" {
  name        = "Loki-Policy-${var.infra_name}"
  description = "loki for S3 policy"
  policy      = file("${path.module}/policy/loki_iam_policy.json")
  depends_on = [ aws_iam_openid_connect_provider.oidc_provider ]
}

# LOKI IAM Role 생성
resource "aws_iam_role" "loki_iam_role" {
  depends_on = [aws_iam_policy.loki_iam_policy]
  name = "Loki-Role-${var.infra_name}"
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Principal: {
                Federated: aws_iam_openid_connect_provider.oidc_provider.arn
            },
            Action: "sts:AssumeRoleWithWebIdentity",
            Condition: {
                StringEquals: {
                    "${local.oidc_provider}:sub": "system:serviceaccount:monitoring:loki-sa",
                    "${local.oidc_provider}:aud": "sts.amazonaws.com"
                }
            }
        },
        {
            Effect: "Allow",
            "Principal": {
                Federated: aws_iam_openid_connect_provider.oidc_provider.arn
            },
            Action: "sts:AssumeRoleWithWebIdentity",
            Condition: {
                StringEquals: {
                    "${local.oidc_provider}:sub": "system:serviceaccount:monitoring:loki-sa-compactor",
                    "${local.oidc_provider}:aud": "sts.amazonaws.com"
                }
            }
        }          
    ]
  })
}

resource "aws_iam_role_policy_attachment" "loki_iam_role_attach" {
    role       = aws_iam_role.loki_iam_role.name
    policy_arn = aws_iam_policy.loki_iam_policy.arn
    depends_on = [ aws_iam_role.loki_iam_role ]
}

# monitoring 네임스페이스 생성
resource "kubernetes_namespace" "monitoring_namespace" {
  metadata {
    name = "monitoring"
  }
  depends_on = [ aws_iam_role_policy_attachment.loki_iam_role_attach ]
}

# loki 배포
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-distributed"
  namespace  = "monitoring"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.loki_iam_role.arn
  }

  set {
    name  = "compactor.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.loki_iam_role.arn
  }

  values = [file("${path.module}/values/loki-values.yaml")]

  depends_on = [ kubernetes_namespace.monitoring_namespace, null_resource.update_storageclass ]
}

# promtail 배포
resource "helm_release" "promtail" {
  name       = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  namespace  = "monitoring"

  values = [file("${path.module}/values/promtail-values.yaml")]

  depends_on = [ helm_release.loki, null_resource.update_storageclass ]
}

# prometheus, grafana 설치
resource "helm_release" "prometheus_grafana" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  depends_on = [ helm_release.promtail, null_resource.update_storageclass ]
}

