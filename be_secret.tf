resource "kubernetes_namespace" "tuktuk_backend" {
  metadata {
    name = "tuktuk-backend"
  }

}

resource "kubernetes_secret" "be_secrets" {
  metadata {
    name = "be-secrets"
    namespace = "tuktuk-backend"
  }

  type = "Opaque"

  data = {
    DATABASE_URL        = var.be_database_url
    MYSQL_ROOT_USERNAME = var.mysql_root_username
    MYSQL_ROOT_PASSWORD = var.mysql_root_password
    AWS_ACCESS_KEY      = var.be_access_key
    AWS_SECRET_KEY      = var.be_secret_key
    AWS_SERVICE_REGION  = var.aws_region
    S3_BUCKET_NAME      = var.be_bucket_name
  }

  depends_on = [ kubernetes_namespace.tuktuk_backend ]
}