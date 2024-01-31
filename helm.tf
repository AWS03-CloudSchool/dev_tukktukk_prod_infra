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
    name  = "server.service.type"
    value = "NodePort"
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

# nginx-ingress 네임스페이스 생성
resource "kubernetes_namespace" "nginx_ingress_namespace" {
  metadata {
    name = "ingress-nginx"
  }
  # depends_on = [ helm_release.argocd ]
}

# nginx-ingress 배포
resource "helm_release" "nginx_ingress" {
  name = "ingress-nginx"
  namespace = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"

  set {
    name = "controller.service.type"
    value = "NodePort"
  }
  depends_on = [ kubernetes_namespace.nginx_ingress_namespace ]
}

# innodb cluster 구축
# mysql-operator 배포
resource "kubernetes_namespace" "mysql_operator_namespace" {
    metadata {
      name = "mysql-operator"
    }
}


resource "helm_release" "mysql_operator" {
    name       = "mysql-operator"
    namespace  = "mysql-operator"
    repository = "https://mysql.github.io/mysql-operator/"
    chart      = "mysql-operator"

    depends_on = [ kubernetes_namespace.mysql_operator_namespace ]
}

resource "kubernetes_namespace" "dev_db_cluster_namespace" {
    metadata {
        name = "dev-db-cluster"
    }
}

resource "helm_release" "dev_db_cluster" {
    name       = "dev-db-cluster"
    namespace  = "dev-db-cluster"
    repository = "https://mysql.github.io/mysql-operator/"
    chart      = "mysql-innodbcluster"

    set {
        name  = "createNamespace"
        value = "true"
    }

    set {
        name  = "credentials.root.user"
        value = "root"
    }

    set {
        name  = "credentials.root.password"
        value = "wedding05"
    }

    set {
        name  = "credentials.root.host"
        value = "%"
    }

    set {
        name  = "serverInstances"
        value = "2"
    }

    set {
        name  = "routerInstances"
        value = "1"
    }
    
    set {
        name = "tls.useSelfSigned"
        value = "true"
    }


    depends_on = [ kubernetes_namespace.dev_db_cluster_namespace , null_resource.update_storageclass ]
}

# # # keycloak 배포
# # resource "kubernetes_namespace" "keycloak_namespace" {
# #     metadata {
# #         name = "keycloak"
# #     }
# # }

# # resource "helm_release" "keycloak" {
# #   name       = "keycloak"
# #   namespace  = "keycloak"
# #   repository = "https://charts.bitnami.com/bitnami/"
# #   chart      = "keycloak"

# #   values = [file("${path.module}/values/keycloak-values.yaml")]

# # }

# # # oauth2_proxy 배포
# # resource "kubernetes_namespace" "oauth2_proxy_namespace" {
# #     metadata {
# #         name = "argocd-oauth-proxy"
# #     }
# # }

# # resource "helm_release" "oauth2_proxy" {
# #   name = "argocd-oauth-proxy"
# #   namespace = "argocd-oauth-proxy"
# #   repository = "https://oauth2-proxy.github.io/manifests"
# #   chart = "oauth2-proxy"

# #   values = [file("${path.module}/values/oauth2proxy-valeus.yaml")]
# # }