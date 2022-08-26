locals {
  region = "europe-west1"
}

variable "kubernetes_name" {
  type        = string
  description = "Please, enter your GKE cluster name"
}

variable "output" {
  description = "GKE connection string"
  type        = string
  default     = "TO CONNECT TO KUBERNETES: gcloud container clusters get-credentials <KUBERNETES-NAME> --region europe-west1 --project elastic-support-k8s-dev"
}

variable "email" {
  type        = string
  description = "Please, enter your email (elastic email) or a user"
}

variable "enable_enterprise" {
  type        = bool
  description = "Do you want to start a 30-day Enterprise trial? Type `true` to activate the trial or `false` if you would like add your own Enterprise license. By selecting 'true', you are expressing that you have accepted the Elastic EULA which can be found at https://www.elastic.co/eula"
}

variable "enterprise_license" {
  type        = string
  description = "Please, enter your (base64-encoded) Enterprise license. Leave blank if not applicable"
}

variable "kibana_endpoint" {
  description = "Kibana endpoint"
  type        = string
  default     = "TO CONNECT TO KIBANA: echo 'https://'$(kubectl get svc --namespace elastic-stack quickstart-kb-http --output jsonpath='{.status.loadBalancer.ingress[0].ip}')':5601'"
}

