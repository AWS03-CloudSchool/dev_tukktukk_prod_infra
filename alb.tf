# ALB IAM Role을 위한 정책 생성
resource "aws_iam_policy" "alb_iam_policy" {
  name        = "alb_iam_policy-${var.infra_name}"
  description = "alb policy"
  policy      = file("${path.module}/policy/alb_iam_policy.json")
  depends_on = [ aws_iam_openid_connect_provider.oidc_provider ]
}

# ALB IAM Role 생성
resource "aws_iam_role" "alb_iam_role" {
  depends_on = [aws_iam_policy.alb_iam_policy]
  name = "alb-irsa-role-${var.infra_name}"
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
            "${local.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_iam_role_attach" {
    role       = aws_iam_role.alb_iam_role.name
    policy_arn = aws_iam_policy.alb_iam_policy.arn
    depends_on = [ aws_iam_role.alb_iam_role ]
}

# aws-load-balancer-controller SA생성
resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = "${aws_iam_role.alb_iam_role.arn}"
    }
  }
  depends_on = [ aws_eks_cluster.dev_cluster, aws_iam_role_policy_attachment.alb_iam_role_attach ,aws_eks_node_group.dev_node_group ]
}

# alb 배포
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.infra_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [ kubernetes_service_account.aws_load_balancer_controller ]
}