# argocd 네임스페이스 생성
resource "kubernetes_namespace" "argocd_namespace" {
  metadata {
    name = "argocd"
  }
  depends_on = [ helm_release.aws_load_balancer_controller ]
}

# argocd 배포
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }

  set {
    name  = "server.service.namedTargetPort"
    value = "false"
  }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

    depends_on = [helm_release.aws_load_balancer_controller ]
}

# argocd
resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name        = "argocd-ingress"
    namespace   = "argocd"
    annotations = {
      "alb.ingress.kubernetes.io/group.name"      = "tuktuk"
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{"HTTPS": 443},{"HTTP": 80}])
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:ap-northeast-2:875522371656:certificate/f207c086-5546-471b-b648-58f6e625d90a"
      "alb.ingress.kubernetes.io/subnets"         = join(",", aws_subnet.public[*].id)
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
    }
  }

  spec {
    rule {
      host = "${var.argocd_sub_dns}.${var.tuktuk_dns}.com"
      http {
        path {
          path = "/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

    depends_on = [ helm_release.argocd ]
}
