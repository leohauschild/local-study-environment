terraform {
  
  backend "local" {
    path = "local_state/terraform.tfstate"
  }

  required_providers {
    helm = {
      source  = "hashicorp/helm",
      version = "2.12.1"
    }
  }
} 

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kind-tools" 
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"
 	
  namespace        = "argocd"
  create_namespace = true

  values = [
    "${file("../defaults/argocd/values.yaml")}"
  ]
}
