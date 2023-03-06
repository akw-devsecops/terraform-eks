# Applied from Pod Security Standards (https://kubernetes.io/docs/concepts/security/pod-security-standards/#policy-instantiation)
resource "kubernetes_pod_security_policy" "privileged" {
  count = var.enable_pod_security_policy ? 1 : 0

  metadata {
    name = "privileged"
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
  count = var.enable_pod_security_policy ? 1 : 0

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
  count = var.enable_pod_security_policy ? 1 : 0

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
