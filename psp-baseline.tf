# Applied from Pod Security Standards (https://kubernetes.io/docs/concepts/security/pod-security-standards/#policy-instantiation)
resource "kubernetes_pod_security_policy" "baseline" {
  count = var.enable_pod_security_policy ? 1 : 0

  metadata {
    name = "baseline"
  }

  spec {
    privileged = false
    allowed_capabilities = [
      "CHOWN",
      "DAC_OVERRIDE",
      "FSETID",
      "FOWNER",
      "MKNOD",
      "SETGID",
      "SETUID",
      "SETFCAP",
      "SETPCAP",
      "NET_BIND_SERVICE",
      "SYS_CHROOT",
      "KILL",
      "AUDIT_WRITE"
    ]
    volumes = [
      # 'core' volume types
      "configMap",
      "emptyDir",
      "projected",
      "secret",
      "downwardAPI",
      "csi",
      "persistentVolumeClaim",
      "ephemeral",
      "csi",
      "persistentVolumeClaim",
      "ephemeral",
      # Allow all other non-hostpath volume types.
      "awsElasticBlockStore",
      "azureDisk",
      "azureFile",
      "cephFS",
      "cinder",
      "fc",
      "flexVolume",
      "flocker",
      "gcePersistentDisk",
      "gitRepo",
      "glusterfs",
      "iscsi",
      "nfs",
      "photonPersistentDisk",
      "portworxVolume",
      "quobyte",
      "rbd",
      "scaleIO",
      "storageos",
      "vsphereVolume"
    ]
    host_network = false
    host_ipc     = false
    host_pid     = false
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
    read_only_root_filesystem = false
  }
}

resource "kubernetes_cluster_role" "baseline" {
  count = var.enable_pod_security_policy && (var.default_pod_security_policy == "baseline") ? 1 : 0

  metadata {
    name = "psp:baseline"
  }

  rule {
    verbs          = ["use"]
    api_groups     = ["extensions"]
    resources      = ["podsecuritypolicies"]
    resource_names = [kubernetes_pod_security_policy.baseline[0].metadata[0].name]
  }
}

resource "kubernetes_cluster_role_binding" "baseline" {
  count = var.enable_pod_security_policy && (var.default_pod_security_policy == "baseline") ? 1 : 0

  metadata {
    name = "psp:baseline"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.baseline[0].metadata[0].name
  }
  subject {
    kind      = "Group"
    api_group = "rbac.authorization.k8s.io"
    name      = "system:serviceaccounts"
  }
}
