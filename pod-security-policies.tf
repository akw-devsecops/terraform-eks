resource "null_resource" "remove_default_privileged_policy" {
  count = var.enable_restricted_security_policy ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
aws eks update-kubeconfig --name ${aws_eks_cluster.cluster-masters.name}
kubectl delete -f ${path.module}/eks-privileged-psp.yaml
EOF
  }
}

# Applied from Pod Security Standards (https://kubernetes.io/docs/concepts/security/pod-security-standards/#policy-instantiation)
resource "kubernetes_pod_security_policy" "restricted" {
  count = var.enable_restricted_security_policy ? 1 : 0

  metadata {
    name = "restricted"
    annotations = {
      "seccomp.security.alpha.kubernetes.io/allowedProfileNames" = "docker/default,runtime/default"
      "apparmor.security.beta.kubernetes.io/allowedProfileNames" = "runtime/default"
      "apparmor.security.beta.kubernetes.io/defaultProfileName"  = "runtime/default"
    }
  }

  spec {
    privileged                 = false
    allow_privilege_escalation = false
    required_drop_capabilities = ["ALL"]
    volumes = [
      "configMap",
      "emptyDir",
      "projected",
      "secret",
      "downwardAPI",
      "csi",
      "persistentVolumeClaim",
      "ephemeral"
    ]
    host_network = false
    host_ipc     = false
    host_pid     = false
    run_as_user {
      rule = "MustRunAsNonRoot"
    }
    se_linux {
      rule = "RunAsAny"
    }
    supplemental_groups {
      rule = "MustRunAs"
      range {
        min = 1
        max = 65535
      }
    }
    fs_group {
      rule = "MustRunAs"
      range {
        min = 1
        max = 65535
      }
    }
    read_only_root_filesystem = false
  }
}

resource "kubernetes_cluster_role" "restricted" {
  count = var.enable_restricted_security_policy ? 1 : 0

  metadata {
    name = "psp:restricted"
  }

  rule {
    verbs          = ["use"]
    api_groups     = ["extensions"]
    resources      = ["podsecuritypolicies"]
    resource_names = [kubernetes_pod_security_policy.restricted[0].metadata[0].name]
  }
}

resource "kubernetes_cluster_role_binding" "restricted" {
  count = var.enable_restricted_security_policy ? 1 : 0

  metadata {
    name = "psp:restricted"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.restricted[0].metadata[0].name
  }
  subject {
    kind      = "Group"
    api_group = "rbac.authorization.k8s.io"
    name      = "system:serviceaccounts"
  }
}

resource "kubernetes_pod_security_policy" "privileged" {
  count = var.enable_restricted_security_policy ? 1 : 0

  metadata {
    name = "privileged"
    annotations = {
      "seccomp.security.alpha.kubernetes.io/allowedProfileNames" = "*"
    }
  }

  spec {
    privileged                         = true
    allow_privilege_escalation         = true
    default_allow_privilege_escalation = true
    allowed_capabilities               = ["*"]
    volumes                            = ["*"]
    host_network                       = true
    host_ports {
      min = 0
      max = 65535
    }
    host_ipc = true
    host_pid = true
    run_as_user {
      rule = "RunAsAny"
    }
    se_linux {
      rule = "RunAsAny"
    }
    supplemental_groups {
      rule = "RunAsAny"
    }
    fs_group {
      rule = "RunAsAny"
    }
  }
}

resource "kubernetes_role" "privileged" {
  count = var.enable_restricted_security_policy ? 1 : 0

  metadata {
    name      = "psp:privileged"
    namespace = "kube-system"
  }

  rule {
    verbs          = ["use"]
    api_groups     = ["extensions"]
    resources      = ["podsecuritypolicies"]
    resource_names = [kubernetes_pod_security_policy.privileged[0].metadata[0].name]
  }
}

resource "kubernetes_role_binding" "privileged" {
  count = var.enable_restricted_security_policy ? 1 : 0

  metadata {
    name      = "psp:privileged"
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.privileged[0].metadata[0].name
  }
  subject {
    kind      = "Group"
    api_group = "rbac.authorization.k8s.io"
    name      = "system:serviceaccounts"
  }
}
