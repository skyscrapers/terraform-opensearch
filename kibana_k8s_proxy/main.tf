terraform {
  required_version = ">= 0.12"
}



data "template_file" "kubesignin_oidc_kibana" {
  template = "${path.module}/templates/kubesignin-oidc-kibana-values-part.yaml.tpl")

  vars = {
    kibana_domain_name = "kibana.${local.cluster_fqdn}"
    kibana_groups      = join(",", concat(["skyscrapers:k8s-admins"], var.kubesignin_k8s_admins_groups, var.kubesignin_kibana_groups))
    elasticsearch_url  = local.elasticsearch_domain_endpoint
  }
}
