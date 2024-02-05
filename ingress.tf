# Frontend 네임스페이스 생성
resource "kubernetes_namespace" "front_namespace" {
  metadata {
    name = "tuktuk-front"
  }
  depends_on = [ helm_release.aws_load_balancer_controller ]
}

# FrontEnd ing 리소스 정의
resource "kubernetes_ingress_v1" "tuktuk-ing" {
  metadata {
    name      = "tuktuk-ing"
    namespace = "tuktuk-front"

    annotations = {
      "alb.ingress.kubernetes.io/group.name"                        = "tuktuk"
      "alb.ingress.kubernetes.io/target-type"                       = "ip"
      "kubernetes.io/ingress.class"                                 = "alb"
      "alb.ingress.kubernetes.io/subnets"                           = join(",", aws_subnet.public[*].id)
      "alb.ingress.kubernetes.io/scheme"                            = "internet-facing"
      "alb.ingress.kubernetes.io/tags"                              = "Environment=prod,Owner=admin"
      "alb.ingress.kubernetes.io/listen-ports"                      = jsonencode([{"HTTPS": 443},{"HTTP": 80}])
      "alb.ingress.kubernetes.io/ssl-redirect"                      = "443"
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
      host = "www.${var.tuktuk_dns}.com"

      http {
        path {
          path = "/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "${var.tuktuk_env}-tuktuk-front-fronttukktukk"
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