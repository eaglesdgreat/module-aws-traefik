provider "helm" {
  kubernetes = {
    config_path            = null
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
    host                   = var.kubernetes_cluster_endpoint

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.kubernetes_cluster_name]
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "helm_release" "traefik-ingress" {
  name          = "ms-traefik-ingress"
  repository    = "https://helm.traefik.io/traefik"
  chart         = "traefik"
  version       = "5.46.8"
  timeout       = 2400 # Increase to 20 minutes
  wait          = true
  wait_for_jobs = true

  values = [<<EOF
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
      externalTrafficPolicy: Local
  EOF
  ]
}
