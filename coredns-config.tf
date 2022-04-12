resource "kubernetes_config_map" "coredns" {
  metadata {
    name      = "coredns"
    namespace = "kube-system"

    labels = {
      "eks.amazonaws.com/component" = "coredns"
      "k8s-app"                     = "kube-dns"
    }
  }

  data = {
    Corefile = <<-EOF
.:53 {
    errors
    health
    kubernetes cluster.local in-addr.arpa ip6.arpa {
        pods insecure
        fallthrough in-addr.arpa ip6.arpa
    }
    prometheus :9153
    forward . /etc/resolv.conf
    cache 30
    loop
    reload
    loadbalance
}
${var.extra_coredns_zones}
EOF
  }
}
