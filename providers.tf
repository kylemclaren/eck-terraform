terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.33.0"
    }
    kubernetes = {
      source  = "hashicorp/helm"
      version = "2.6.0"
      source  = "hashicorp/kubernetes"
      version = "2.13.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host = "https://${google_container_cluster._.endpoint}"
    #    config_path    = "~/.kube/config"

    client_certificate     = base64decode(google_container_cluster._.master_auth.0.client_certificate)
    client_key             = base64decode(google_container_cluster._.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(google_container_cluster._.master_auth.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host = "https://${google_container_cluster._.endpoint}"
  #  config_path    = "~/.kube/config"

  client_certificate     = base64decode(google_container_cluster._.master_auth.0.client_certificate)
  client_key             = base64decode(google_container_cluster._.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(google_container_cluster._.master_auth.0.cluster_ca_certificate)

}
