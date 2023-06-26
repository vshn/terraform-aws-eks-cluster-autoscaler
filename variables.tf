variable "cluster_name" {
  description = "AWS EKS Cluster Name"
  type        = string
}

variable "aws_region" {
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
