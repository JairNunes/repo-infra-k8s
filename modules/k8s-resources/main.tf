terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "auto-repair-shop"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_config_map" "app" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    PORT                = "3000"
    NODE_ENV            = "production"
    JWT_EXPIRES_IN      = "24h"
    DATABASE_URL        = var.database_url
    NEW_RELIC_APP_NAME  = "oficina-mecanica-api"
    NEW_RELIC_LOG_LEVEL = "info"
    NOTIFY_LAMBDA_URL   = var.notify_lambda_url
  }
}

resource "kubernetes_secret" "app" {
  metadata {
    name      = "app-secrets"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    JWT_SECRET            = var.jwt_secret
    ADMIN_EMAIL           = var.admin_email
    ADMIN_PASSWORD        = var.admin_password
    NEW_RELIC_LICENSE_KEY = var.new_relic_license_key
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "auto-repair-shop-api"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "auto-repair-shop-api"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "auto-repair-shop-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "auto-repair-shop-api"
        }
      }

      spec {
        container {
          name              = "api"
          image             = "${var.image_repository}:${var.image_tag}"
          image_pull_policy = "Always"

          port {
            container_port = 3000
            name           = "http"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.app.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.app.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = 20
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = 40
            period_seconds        = 20
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "auto-repair-shop-api"
    namespace = kubernetes_namespace.app.metadata[0].name
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
    }
  }

  spec {
    selector = {
      app = "auto-repair-shop-api"
    }
    port {
      port        = 80
      target_port = 3000
      protocol    = "TCP"
      name        = "http"
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "app" {
  metadata {
    name      = "auto-repair-shop-api-hpa"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.app.metadata[0].name
    }
    min_replicas = 2
    max_replicas = 10

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 80
        }
      }
    }

    behavior {
      scale_up {
        stabilization_window_seconds = 0
        policy {
          type           = "Percent"
          value          = 100
          period_seconds = 30
        }
      }
      scale_down {
        stabilization_window_seconds = 300
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 60
        }
      }
    }
  }
}
