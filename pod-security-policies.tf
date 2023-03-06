resource "null_resource" "remove_default_privileged_policy" {
  count = var.enable_pod_security_policy ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
aws eks update-kubeconfig --name ${aws_eks_cluster.cluster-masters.name}
kubectl delete -f ${path.module}/eks-privileged-psp.yaml
EOF
  }
}
