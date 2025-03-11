module "cluster_autoscaler_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.54.0"

  role_name                        = format("%s-cluster-autoscaler-role", var.cluster_name)
  role_description                 = format("Allows %s assume role permissions in %s", var.cluster_name, var.region)
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [var.cluster_name]

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

resource "kubernetes_labels" "kube_system_monitoring" {
  count = var.cluster_autoscaler_servicemonitor_enabeld ? 1 : 0

  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "kube-system"
  }
  labels = {
    "monitoring.syn.tools/infra" = "true"
  }
}

resource "helm_release" "cluster_autoscaler" {
  atomic          = true
  chart           = var.cluster_autoscaler_helm_chart_name
  cleanup_on_fail = true
  name            = var.cluster_autoscaler_helm_chart_name
  namespace       = "kube-system"
  repository      = var.cluster_autoscaler_helm_chart_repository
  timeout         = 600
  version         = var.cluster_autoscaler_helm_chart_version

  # Keep this issue in mind when running autoscaler, especially if you are seeing OOMKilled errors.
  # https://github.com/kubernetes/autoscaler/issues/3506
  values = [
    yamlencode({
      "autoDiscovery" : {
        "clusterName" : var.cluster_name,
      }
      "awsRegion" : var.region
      "cloudProvider" : "aws"
      "extraArgs" : {
        "balance-similar-node-groups" : true,
        "expander" : "least-waste",
        "node-group-auto-discovery" : "asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${var.cluster_name}"
        "skip-nodes-with-system-pods" : false,
        "skip-nodes-with-local-storage" : false,
      }
      "extraVolumes" : [
        {
          "name" : "ssl-certs",
          "hostPath" : {
            "path" : "/etc/ssl/certs/ca-bundle.crt"
          }
        }
      ]
      "extraVolumeMounts" : [
        {
          "name" : "ssl-certs",
          "mountPath" : "/etc/ssl/certs/ca-certificates.crt",
          "readOnly" : true
        }
      ]
      "rbac" : {
        "create" : true,
        "serviceAccount" : {
          "annotations" : {
            "eks.amazonaws.com/role-arn" : module.cluster_autoscaler_irsa_role.iam_role_arn
          },
          "create" : true,
          "name" : "cluster-autoscaler",
          "automountServiceAccountToken" : true
        }
      }
      "replicaCount" : "1"
      "resources" : {
        "limits" : {
          "cpu" : "100m",
          "memory" : "250Mi"
        },
        "requests" : {
          "cpu" : "25m",
          "memory" : "100Mi"
        }
      }
      "serviceMonitor" : {
        "enabled" : var.cluster_autoscaler_servicemonitor_enabeld
        "namespace" : "kube-system"
        "selector" : var.cluster_autoscaler_servicemonitor_selectors
      }
    })
  ]
}
