variable "cluster_name" {
  description = "AWS EKS Cluster Name"
  type        = string
}

variable "region" {
  description = "Region of the AWS EKS Cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC Provider ARN which is used by AWS EKS Cluster"
  type        = string
}

variable "cluster_autoscaler_helm_chart_name" {
  description = "The name of the Helm chart in the repository for cluster autoscaler."
  type        = string
  default     = "cluster-autoscaler"
}

variable "cluster_autoscaler_helm_chart_repository" {
  description = "The repository containing the cluster-autoscaler helm chart."
  type        = string
  default     = "https://kubernetes.github.io/autoscaler"
}

variable "cluster_autoscaler_helm_chart_version" {
  description = "Helm chart version for the cluster-autoscaler. See https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler for more details."
  type        = string
}

variable "cluster_autoscaler_servicemonitor_enabeld" {
  description = "If true, creates a Prometheus Operator ServiceMonitor."
  type        = bool
  default     = true
}

variable "cluster_autoscaler_servicemonitor_selectors" {
  description = "ServiceMonitor labels for prometheus operator."
  type        = map(string)
  default = {
    "monitoring.syn.tools/enabled" : "true"
  }
}
