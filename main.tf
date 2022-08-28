# This blocks creates the Kubernetes cluster
resource "google_container_cluster" "_" {
  name     = var.kubernetes_name
  location = local.region

  node_pool {
    name = "builtin"
  }
  lifecycle {
    ignore_changes = [node_pool]
  }
}

# Creating and attaching the node-pool to the Kubernetes Cluster
resource "google_container_node_pool" "node-pool" {
  name               = "node-pool"
  cluster            = google_container_cluster._.id
  initial_node_count = 1

  node_config {
    preemptible  = false
    machine_type = "e2-standard-4"
  }
}

# Create the cluster role binding to give the user the privileges to create resources into Kubernetes
resource "kubernetes_cluster_role_binding" "cluster-admin-binding" {
  metadata {
    name = "cluster-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = var.email
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [google_container_cluster._, google_container_node_pool.node-pool]
}

# Install ECK operator via helm-charts
resource "helm_release" "elastic" {
  name = "elastic-operator"

  repository       = "https://helm.elastic.co"
  chart            = "eck-operator"
  version          = "2.4.0"
  namespace        = "elastic-system"
  create_namespace = "true"

  depends_on = [google_container_cluster._, google_container_node_pool.node-pool, kubernetes_cluster_role_binding.cluster-admin-binding]

}

# Delay of 5m to wait until ECK operator is up and running
resource "time_sleep" "wait_30_seconds" {
  depends_on = [helm_release.elastic]

  create_duration = "30s"
}

resource "time_sleep" "wait_for_trial" {
  depends_on = [kubernetes_secret_v1.start_trial]

  create_duration = "30s"
}

resource "time_sleep" "wait_for_license" {
  depends_on = [kubernetes_secret_v1.enterprise_license]

  create_duration = "30s"
}

resource "helm_release" "elastic_quickstart" {
  name = "quickstart"

  repository       = "https://helm.elastic.co"
  chart            = "eck-stack"
  namespace        = "elastic-stack"
  create_namespace = "true"

  values = [
    file("${path.module}/quickstart-values.yaml")
  ]

  depends_on = [helm_release.elastic, time_sleep.wait_30_seconds, time_sleep.wait_for_trial, time_sleep.wait_for_license]

}

# We need to start an Enterprise trial or the helm release of Elastic stack will fail: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-licensing.html
resource "kubernetes_secret_v1" "start_trial" {
  count = var.enable_enterprise ? 1 : 0
  metadata {
    name      = "eck-trial-license"
    namespace = "elastic-system"
    labels = {
      "license.k8s.elastic.co/type" = "enterprise_trial"
    }
    annotations = {
      "elastic.co/eula" = "accepted"
    }
  }

  depends_on = [helm_release.elastic]

}

resource "kubernetes_secret_v1" "enterprise_license" {
  count = var.enable_enterprise ? 0 : 1
  metadata {
    name      = "eck-license"
    namespace = "elastic-system"
    labels = {
      "license.k8s.elastic.co/scope" = "operator"
    }
  }
  data = {
    "license" = "${file("${path.module}/license.json")}"
  }
  depends_on = [helm_release.elastic]
}
