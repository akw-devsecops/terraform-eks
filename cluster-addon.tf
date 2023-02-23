resource "aws_eks_addon" "kube_proxy" {
  count = var.create_eks_addons ? 1 : 0

  cluster_name      = var.cluster-name
  addon_name        = "kube-proxy"
  addon_version     = var.eks_addon_version_kube_proxy
  resolve_conflicts = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.cluster-masters
  ]
}

resource "aws_eks_addon" "core_dns" {
  count = var.create_eks_addons && var.enable_coredns_addon ? 1 : 0

  cluster_name      = var.cluster-name
  addon_name        = "coredns"
  addon_version     = var.eks_addon_version_core_dns
  resolve_conflicts = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.cluster_nodes
  ]
}

locals {
  prefix_delegation_configuration = var.node_increase_pod_limit ? {
    ENABLE_PREFIX_DELEGATION = "true"
    WARM_IP_TARGET           = 5
    MINIMUM_IP_TARGET        = 2
  } : {}

  custom_networking_configuration = var.enable_custom_networking ? {
    AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
    ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
  } : {}
}

resource "aws_eks_addon" "vpc-cni" {
  count = var.create_eks_addons ? 1 : 0

  cluster_name      = var.cluster-name
  addon_name        = "vpc-cni"
  addon_version     = var.eks_addon_version_vpc_cni
  resolve_conflicts = "OVERWRITE"

  configuration_values = jsonencode({
    env = merge(local.prefix_delegation_configuration, local.custom_networking_configuration)
  })

  depends_on = [
    aws_eks_cluster.cluster-masters
  ]
}
