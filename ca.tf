# CA IAM Role을 위한 정책 설정
resource "aws_iam_policy" "ca_iam_policy" {
  name        = "ca_iam_policy-${var.infra_name}"
  description = "ca policy"
  policy      = file("${path.module}/policy/ca_iam_policy.json")
  depends_on = [ aws_iam_openid_connect_provider.oidc_provider ]
}

# CA IAM Role 생성
resource "aws_iam_role" "ca_iam_role" {
  depends_on = [aws_iam_policy.ca_iam_policy]
  name = "ca-irsa-role-${var.infra_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc_provider.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${local.oidc_provider}:aud" = "sts.amazonaws.com",
            "${local.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-cluster-autoscaler"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ca_iam_role_attach" {
    role       = aws_iam_role.ca_iam_role.name
    policy_arn = aws_iam_policy.ca_iam_policy.arn
    depends_on = [aws_iam_role.ca_iam_role]
}

# 매트릭 서버 배포
resource "helm_release" "metrics_server" {
  name = "metrics-server"
  namespace = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart = "metrics-server"

  depends_on = [ helm_release.aws_load_balancer_controller ]
}

# aws-cluster-autoscaler SA생성
resource "kubernetes_service_account" "aws-cluster-autoscaler" {
  metadata {
    name      = "aws-cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${aws_iam_role.ca_iam_role.arn}"
    }
  }
  depends_on = [ helm_release.metrics_server ]
}

# ca 배포
resource "helm_release" "cluster_autoscaler" {
  name       = "aws-cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.dev_cluster.name
  }

  set {
    name  = "awsRegion"
    value = "ap-northeast-2"
  }


  set {
    name  = "rbac.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "aws-cluster-autoscaler"
  }


  depends_on = [ kubernetes_service_account.aws-cluster-autoscaler ]
}