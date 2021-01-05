# terraform-awselasticsearch

## elasticsearch

Terraform module to setup all resources needed for setting up an AWS Elasticsearch Service domain.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| name | Name to use for the Elasticsearch domain | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| volume_size | EBS volume size (in GB) to use for the Elasticsearch domain | `number` | n/a | yes |
| application_logging_enabled | Whether to enable Elasticsearch application logs in Cloudwatch | `bool` | `false` | no |
| availability_zone_count | Number of Availability Zones for the domain to use with zone_awareness_enabled.Valid values: 2 or 3. Automatically configured through number of instances/subnets available if not set. | `number` | `null` | no |
| cognito_enabled | Whether to enable Cognito for authentication in Kibana | `bool` | `false` | no |
| cognito_identity_pool_id | Required when cognito_enabled is enabled: ID of the Cognito Identity Pool to use | `string` | `null` | no |
| cognito_role_arn | Required when `cognito_enabled` is enabled: ARN of the IAM role that has the AmazonESCognitoAccess policy attached | `string` | `null` | no |
| cognito_user_pool_id | Required when cognito_enabled is enabled: ID of the Cognito User Pool to use | `string` | `null` | no |
| dedicated_master_count | Number of dedicated master nodes in the domain | `number` | `1` | no |
| dedicated_master_enabled | Whether dedicated master nodes are enabled for the domain | `bool` | `false` | no |
| dedicated_master_type | Instance type of the dedicated master nodes in the domain | `string` | `"t2.small.elasticsearch"` | no |
| elasticsearch_version | Version of the Elasticsearch domain | `string` | `"6.7"` | no |
| encrypt_at_rest | Whether to enable encryption at rest for the cluster. Changing this on an existing cluster will force a new resource! | `bool` | `true` | no |
| instance_count | Size of the Elasticsearch domain | `number` | `1` | no |
| instance_type | Instance type to use for the Elasticsearch domain | `string` | `"t2.small.elasticsearch"` | no |
| logging_enabled | Whether to enable Elasticsearch slow logs in Cloudwatch | `bool` | `false` | no |
| logging_retention | How many days to retain Elasticsearch logs in Cloudwatch | `number` | `30` | no |
| options_indices_fielddata_cache_size | Sets the `indices.fielddata.cache.size` advanced option. Specifies the percentage of heap space that is allocated to fielddata | `number` | `null` | no |
| options_indices_query_bool_max_clause_count | Sets the `indices.query.bool.max_clause_count` advanced option. Specifies the maximum number of allowed boolean clauses in a query | `number` | `1024` | no |
| options_rest_action_multi_allow_explicit_index | Sets the `rest.action.multi.allow_explicit_index` advanced option. When set to `false`, Elasticsearch will reject requests that have an explicit index specified in the request body | `bool` | `true` | no |
| security_group_ids | Extra security group IDs to attach to the Elasticsearch domain. Note: a default SG is already created and exposed via outputs | `list(string)` | `[]` | no |
| snapshot_bucket_enabled | Whether to create a bucket for custom Elasticsearch backups (other than the default daily one) | `bool` | `false` | no |
| snapshot_start_hour | Hour during which an automated daily snapshot is taken of the Elasticsearch indices | `number` | `3` | no |
| subnet_ids | Required if vpc_id is specified: Subnet IDs for the VPC enabled Elasticsearch domain endpoints to be created in | `list(string)` | `[]` | no |
| tags | Optional tags | `map(string)` | `{}` | no |
| volume_iops | Required if volume_type="io1": Amount of provisioned IOPS for the EBS volume | `number` | `0` | no |
| volume_type | EBS volume type to use for the Elasticsearch domain | `string` | `"gp2"` | no |
| vpc_id | VPC ID where to deploy the Elasticsearch domain. If set, you also need to specify `subnet_ids`. If not set, the module creates a public domain | `string` | `null` | no |
| zone_awareness_enabled | Whether to enable zone_awareness or not, if not set, multi az is enabled by default and configured through number of instances/subnets available | `bool` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| arn | ARN of the Elasticsearch domain |
| domain\_id | ID of the Elasticsearch domain |
| domain\_name | Name of the Elasticsearch domain |
| domain\_region | Region of the Elasticsearch domain |
| endpoint | DNS endpoint of the Elasticsearch domain |
| role\_arn | ARN of the IAM role (eg to attach to an instance or user) allowing access to the Elasticsearch snapshot bucket |
| role\_id | ID of the IAM role (eg to attach to an instance or user) allowing access to the Elasticsearch snapshot bucket |
| sg\_id | ID of the Elasticsearch security group |

### Example

```terraform
module "elasticsearch" {
  source        = "github.com/skyscrapers/terraform-awselasticsearch//elasticsearch?ref=4.0.0"
  name           = "es"
  project        = var.project
  environment    = terraform.workspace
  instance_count = 3
  instance_type  = "m5.large.elasticsearch"
  volume_size    = 100
  vpc_id         = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids     = data.terraform_remote_state.networking.outputs.private_db_subnets
}

resource "aws_elasticsearch_domain_policy" "es_policy" {
  domain_name = "${module.elasticsearch.domain_name}"

  access_policies = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": [
              "AWS": "${aws_iam_user.es_user.arn}"
            ],
            "Effect": "Allow",
            "Resource": "${module.elasticsearch.arn}/*"
        }
    ]
}
POLICY
}
```

### Backups

The AWS Elasticsearch Service handles backups automatically via daily snapshots. You can control when this happens by setting `snapshot_start_hour`.

It's possible to create a custom backup schedule by using the normal Elasticsearch API for snapshotting. This module can create an S3 bucket and IAM role allowing such scenario's (`snapshot_bucket_enabled = true`). More info on how to create custom snapshots can be found in the [AWS documentation](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-managedomains-snapshots.html).

### Logging

This module by default creates Cloudwatch Log Groups & IAM permissions for ElasticSearch slow logging, but we don't enable these logs by default. You can control logging behavior via the `logging_enabled` and `logging_retention` parameters. When enabling this, make sure you also enable this on Elasticsearch side, following the [AWS documentation](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-createupdatedomains.html#es-createdomain-configure-slow-logs).

### Monitoring

This module generates a Helm values file which can be used for the [`elasticsearch/monitoring`](https://github.com/skyscrapers/charts/elasticsearch-monitoring) chart.

The file, `helm_values.yaml` needs to be created in the same folder as the Terraform code that is calling this module.

### NOTES

This module will not work without the ES default role [AWSServiceRoleForAmazonElasticsearchService](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/slr-es.html). This service role needs to be created per-account so you will need to add it if not present (just once per AWS account).

Here is a code sample you can use:

```terraform
resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}
```

## elasticsearch_k8s_monitoring

This module deploys our [`elasticsearch/monitoring`](https://github.com/skyscrapers/charts/elasticsearch-monitoring) chart on Kubernetes.

### Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.24 |
| aws | >= 2.55.0 |
| helm | >= 1.1.1 |
| kubernetes | >= 1.11.1 |

### Providers

| Name | Version |
|------|---------|
| helm | >= 1.1.1 |
| template | n/a |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudwatch_exporter_role_arn | IAM role ARN to use for the CloudWatch exporter. Used via either IRSA or kube2iam (see `var.irsa_enabled`) | `string` | n/a | yes |
| elasticsearch_domain_name | Domain name of the AWS Elasticsearch domain | `string` | n/a | yes |
| elasticsearch_domain_region | Region of the AWS Elasticsearch domain | `string` | n/a | yes |
| elasticsearch_endpoint | Endpoint of the AWS Elasticsearch domain | `string` | n/a | yes |
| kubernetes_namespace | Kubernetes namespace where to deploy the `skyscrapers/elasticsearch-monitoring` chart | `string` | n/a | yes |
| elasticsearch_monitoring_chart_version | elasticsearch-monitoring Helm chart version to deploy | `string` | `"1.2.3"` | no |
| force_helm_update | Modify this variable to trigger an update on all Helm charts (you can set any value). Due to current limitations of the Helm provider, it doesn't detect drift on the deployed values | `string` | `"1"` | no |
| irsa_enabled | Whether to use [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html). When `true`, the Cloudwatch exporter's SA is appropriately annotated. If `false` a [kube2iam](https://github.com/jtblin/kube2iam) Pod annotation is set instead | `bool` | `true` | no |

### Outputs

No output.

## kibana_k8s_auth_ingress

This module deploys an Ingress with [external authentication](https://kubernetes.github.io/ingress-nginx/examples/auth/oauth-external-auth/) on Kubernetes to reach the AWS Elasticsearch Kibana endpoint.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| elasticsearch\_endpoint | Endpoint of the AWS Elasticsearch domain | string | n/a | yes |
| elasticsearch\_domain\_name | Domain name of the AWS Elasticsearch domain | string | n/a | yes |
| kubernetes\_namespace | Kubernetes namespace where to deploy the Ingress | string | n/a | yes |
| ingress\_host | Hostname to use for the Ingress | string | n/a | yes |
| ingress\_auth\_url | Value to set for the `nginx.ingress.kubernetes.io/auth-url` annotation | string | n/a | yes |
| ingress\_auth\_signin | Value to set for the `nginx.ingress.kubernetes.io/auth-signin` annotation | string | n/a | yes |
| ingress\_auth\_configuration\_snippet | Value to set for the `nginx.ingress.kubernetes.io/configuration-snippet` annotation | string | `null` | no |

## kibana_k8s_auth_proxy

This module deploys [keycloack-gatekeeper](https://github.com/keycloak/keycloak-gatekeeper) as OIDC proxy on Kubernetes to reach the AWS Elasticsearch Kibana endpoint.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| elasticsearch\_endpoint | Endpoint of the AWS Elasticsearch domain | string | n/a | yes |
| elasticsearch\_domain\_name | Domain name of the AWS Elasticsearch domain | string | n/a | yes |
| kubernetes\_namespace | Kubernetes namespace where to deploy the Keycloack-gatekeeper proxy chart | string | n/a | yes |
| gatekeeper\_image | Docker image to use for the Keycloack-gatekeeper deployment | string | `"keycloak/keycloak-gatekeeper:6.0.1"` | no |
| gatekeeper\_ingress\_host | Hostname to use for the Ingress | string | n/a | yes |
| gatekeeper\_discovery\_url | URL for OpenID autoconfiguration | string | n/a | yes |
| gatekeeper\_client\_id | Client ID for OpenID server | string | n/a | yes |
| gatekeeper\_client\_secret | Client secret for OpenID server | string | n/a | yes |
| gatekeeper\_oidc\_groups | Groups that will be granted access. When using Dex with GitHub, teams are defined in the form `<gh_org>:<gh_team>`, for example `skyscrapers:k8s-admins` | string | n/a | yes |
| gatekeeper\_timeout | Upstream timeouts to use for the proxy | string | `"500s"` | no |
| gatekeeper\_extra\_args | Additional keycloack-gatekeeper command line arguments | list(string) | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| callback\_uri | Callback URI. You might need to register this to your OIDC provider (like CoreOS Dex) |
