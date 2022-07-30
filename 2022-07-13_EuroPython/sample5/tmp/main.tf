variable "mock" { type = bool }

resource "aws_eks_cluster" "cluster1" {
  name     = "cluster1"
  role_arn = aws_iam_role.test.arn

  vpc_config {
    subnet_ids = [data.aws_subnets.default.id]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_iam_role" "test" {
  name = "test_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


# Kubernetes app config below

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k3d-cluster1"
}

resource "kubernetes_pod" "nginx" {
  count = var.mock ? 0 : 1

  metadata {
    name = "tf-nginx"
    labels = {
      app = "MyApp"
    }
  }

  spec {
    container {
      image = "nginx:1.21.6"
      name  = "nginx"
    }
  }

  # make sure we deploy only once the cluster is available
  depends_on = [aws_eks_cluster.cluster1]
}

resource "kubernetes_service" "nginx" {
  count = var.mock ? 0 : 1

  metadata {
    name = "tf-nginx"
  }
  spec {
    selector = {
      app = kubernetes_pod.nginx[0].metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 8080
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

# define ingress
resource "kubernetes_manifest" "nginx-ingress" {
  count = var.mock ? 0 : 1

  manifest = yamldecode(<<EOF
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: nginx
      namespace: default
      annotations:
        ingress.kubernetes.io/ssl-redirect: "false"
    spec:
      rules:
      - http:
          paths:
          - path: /app1
            pathType: Prefix
            backend:
              service:
                name: tf-nginx
                port:
                  number: 8080
    EOF
  )

  depends_on = [kubernetes_service.nginx]
}
