# ALB ingress 리소스 정의
resource "kubernetes_ingress_v1" "nginx_ingress" {
  metadata {
    name        = "nginx-ingress"
    namespace   = "ingress-nginx"
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([{"HTTPS": 443},{"HTTP": 80}])
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:ap-northeast-2:875522371656:certificate/f207c086-5546-471b-b648-58f6e625d90a"
      "alb.ingress.kubernetes.io/subnets" = join(",", aws_subnet.public[*].id)
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
      # # Cognito setting 
      # "alb.ingress.kubernetes.io/auth-type" = "cognito"
      # "alb.ingress.kubernetes.io/auth-scope" = "openid"
      # "alb.ingress.kubernetes.io/auth-session-timeout" = "3600"
      # "alb.ingress.kubernetes.io/auth-session-cookie" = "AWSELBAuthSessionCookie"
      # "alb.ingress.kubernetes.io/auth-on-unauthenticated-request" = "authenticate"
      # "alb.ingress.kubernetes.io/auth-idp-cognito" = jsonencode({"UserPoolArn": "arn:aws:cognito-idp:ap-northeast-2:875522371656:userpool/ap-northeast-2_OphatQD53", "UserPoolClientId": "b6724nf887535v4aohlffe1ep", "UserPoolDomain": "tukktukk"})
    }
    labels = {
      "app" = "nginx-ingress"
    }
  }

  spec {
    rule {
      host = "*.tukktukk.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "ingress-nginx-controller"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [ helm_release.nginx_ingress ]
}

# tuktuk-front 네임스페이스 생성
resource "kubernetes_namespace" "front_namespace" {
  metadata {
    name = "tuktuk-front"
  }
}

resource "kubernetes_ingress_v1" "tuktuk-ing" {
  metadata {
    name      = "tuktuk-ing"
    namespace = "tuktuk-front"

    annotations = {
      "kubernetes.io/ingress.class"                                 = "alb"
      "alb.ingress.kubernetes.io/subnets"                           = join(",", aws_subnet.public[*].id)
      "alb.ingress.kubernetes.io/scheme"                            = "internet-facing"
      "alb.ingress.kubernetes.io/tags"                              = "Environment=dev,Owner=admin"
      "alb.ingress.kubernetes.io/listen-ports"                      = jsonencode([{"HTTPS": 443},{"HTTP": 80}])
      "alb.ingress.kubernetes.io/ssl-redirect"              = "443"
      "alb.ingress.kubernetes.io/auth-type"                         = "cognito"
      "alb.ingress.kubernetes.io/auth-scope"                        = "openid"
      "alb.ingress.kubernetes.io/auth-session-timeout"              = "3600"
      "alb.ingress.kubernetes.io/auth-session-cookie"               = "AWSELBAuthSessionCookie"
      "alb.ingress.kubernetes.io/auth-on-unauthenticated-request"   = "authenticate"
      "alb.ingress.kubernetes.io/auth-idp-cognito"                  = jsonencode({"UserPoolArn": "arn:aws:cognito-idp:ap-northeast-2:875522371656:userpool/ap-northeast-2_CvpIITi4y", "UserPoolClientId": "mmkq2evci6d21fjs553tnibk3", "UserPoolDomain": "tuktuk"})
      "alb.ingress.kubernetes.io/certificate-arn"                   = "arn:aws:acm:ap-northeast-2:875522371656:certificate/f207c086-5546-471b-b648-58f6e625d90a"
    }
  }

  spec {
    rule {
      host = "${var.app_sub_dns}.tukktukk.com"

      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "tuktuk-front-fronttukktukk"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
  depends_on = [ kubernetes_namespace.front_namespace ]
}

# argocd ingress 정의
resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "kubernetes.io/ingress.class"                = "nginx"
    }
  }

  spec {
    rule {
      host = "${var.argocd_sub_dns}.tukktukk.com"
      http {
        path {
          path = "/"
          path_type = "Prefix"
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

  depends_on = [ kubernetes_ingress_v1.nginx_ingress ]
}

# grafana ingress 정의
resource "kubernetes_ingress_v1" "grafana_ingress" {
  metadata {
    name = "grafana-ingress"
    namespace = "monitoring"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "kubernetes.io/ingress.class"                = "nginx"
    }
  }

  spec {
    rule {
      host = "${var.grafana_sub_dns}.tukktukk.com"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [ kubernetes_namespace.monitoring_namespace,kubernetes_ingress_v1.nginx_ingress ]
}

