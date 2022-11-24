# Simple Kubernetes app config (nginx server)

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k3d-cluster1"
}

resource "kubernetes_pod" "nginx" {
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
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "tf-nginx"
  }
  spec {
    selector = {
      app = kubernetes_pod.nginx.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 8080
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

# define ingress as custom manifest, as we depend on a specific apiVersion
resource "kubernetes_manifest" "nginx-ingress" {
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

resource "kubernetes_manifest" "nginx-ingress2" {
  manifest = yamldecode(<<EOF
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: nginx2
      namespace: default
      annotations:
        ingress.kubernetes.io/ssl-redirect: "false"
    spec:
      rules:
      - http:
          paths:
          - path: /app2
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
