# Applied from Pod Security Standards (https://kubernetes.io/docs/concepts/security/pod-security-standards/#policy-instantiation)
resource "kubernetes_pod_security_policy" "restricted" {
  count = var.enable_pod_security_policy ? 1 : 0

  metadata {
    name = "restricted"
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
  count = var.enable_pod_security_policy && (var.default_pod_security_policy == "restricted") ? 1 : 0

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
  count = var.enable_pod_security_policy && (var.default_pod_security_policy == "restricted") ? 1 : 0

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
