# terraform-opensearch

- [terraform-opensearch](#terraform-opensearch)
  - [opensearch](#opensearch)
    - [Requirements](#requirements)
    - [Providers](#providers)
    - [Modules](#modules)
    - [Resources](#resources)
    - [Inputs](#inputs)
    - [Outputs](#outputs)
    - [Example](#example)
    - [Logging](#logging)
    - [Monitoring](#monitoring)
    - [NOTES](#notes)
  - [opensearch-backup](#opensearch-backup)
    - [Requirements](#requirements-1)
    - [Providers](#providers-1)
    - [Modules](#modules-1)
    - [Resources](#resources-1)
    - [Inputs](#inputs-1)
    - [Outputs](#outputs-1)
    - [Example](#example-1)
  - [elasticsearch\_k8s\_monitoring](#elasticsearch_k8s_monitoring)
    - [Requirements](#requirements-2)
    - [Providers](#providers-2)
    - [Modules](#modules-2)
    - [Resources](#resources-2)
    - [Inputs](#inputs-2)
    - [Outputs](#outputs-2)
  - [kibana\_k8s\_auth\_ingress](#kibana_k8s_auth_ingress)
    - [Requirements](#requirements-3)
    - [Providers](#providers-3)
    - [Inputs](#inputs-3)
    - [Outputs](#outputs-3)
  - [kibana\_k8s\_auth\_proxy](#kibana_k8s_auth_proxy)
    - [Inputs](#inputs-4)
    - [Outputs](#outputs-4)
  - [Upgrading](#upgrading)
    - [Version 10.0.0 to 11.0.0](#version-1000-to-1100)
    - [Version 9.1.4 to 10.0.0](#version-914-to-1000)
    - [Version 8.0.0 to 8.2.0](#version-800-to-820)
    - [Version 7.0.0 to 8.0.0](#version-700-to-800)
    - [Version 6.0.0 to 7.0.0](#version-600-to-700)

## opensearch

Terraform module to setup all resources needed for setting up an AWS OpenSearch Service domain.

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3.9, < 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 5.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 5.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.cwl_application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.cwl_index](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.cwl_search](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.cwl_resource_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_elasticsearch_domain.es](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_iam_policy_document.cwl_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_type"></a> [instance_type](#input_instance_type) | Instance type to use for the OpenSearch domain | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input_name) | Name to use for the OpenSearch domain | `string` | n/a | yes |
| <a name="input_volume_size"></a> [volume_size](#input_volume_size) | EBS volume size (in GB) to use for the OpenSearch domain | `number` | n/a | yes |
| <a name="input_application_logging_enabled"></a> [application_logging_enabled](#input_application_logging_enabled) | Whether to enable OpenSearch application logs (error) in Cloudwatch | `bool` | `false` | no |
| <a name="input_availability_zone_count"></a> [availability_zone_count](#input_availability_zone_count) | Number of Availability Zones for the domain to use with zone_awareness_enabled.Valid values: 2 or 3. Automatically configured through number of instances/subnets available if not set. | `number` | `null` | no |
| <a name="input_cognito_enabled"></a> [cognito_enabled](#input_cognito_enabled) | Whether to enable Cognito for authentication in Kibana | `bool` | `false` | no |
| <a name="input_cognito_identity_pool_id"></a> [cognito_identity_pool_id](#input_cognito_identity_pool_id) | Required when cognito_enabled is enabled: ID of the Cognito Identity Pool to use | `string` | `null` | no |
| <a name="input_cognito_role_arn"></a> [cognito_role_arn](#input_cognito_role_arn) | Required when `cognito_enabled` is enabled: ARN of the IAM role that has the AmazonESCognitoAccess policy attached | `string` | `null` | no |
| <a name="input_cognito_user_pool_id"></a> [cognito_user_pool_id](#input_cognito_user_pool_id) | Required when cognito_enabled is enabled: ID of the Cognito User Pool to use | `string` | `null` | no |
| <a name="input_custom_endpoint"></a> [custom_endpoint](#input_custom_endpoint) | The domain name to use as custom endpoint for Elasicsearch | `string` | `null` | no |
| <a name="input_custom_endpoint_certificate_arn"></a> [custom_endpoint_certificate_arn](#input_custom_endpoint_certificate_arn) | ARN of the ACM certificate to use for the custom endpoint. Required when custom endpoint is set along with enabling `endpoint_enforce_https` | `string` | `null` | no |
| <a name="input_dedicated_master_count"></a> [dedicated_master_count](#input_dedicated_master_count) | Number of dedicated master nodes in the domain (can be 3 or 5) | `number` | `3` | no |
| <a name="input_dedicated_master_enabled"></a> [dedicated_master_enabled](#input_dedicated_master_enabled) | Whether dedicated master nodes are enabled for the domain. Automatically enabled when `warm_enabled = true` | `bool` | `false` | no |
| <a name="input_dedicated_master_type"></a> [dedicated_master_type](#input_dedicated_master_type) | Instance type of the dedicated master nodes in the domain | `string` | `"t3.small.search"` | no |
| <a name="input_encrypt_at_rest"></a> [encrypt_at_rest](#input_encrypt_at_rest) | Whether to enable encryption at rest for the cluster. Changing this on an existing cluster will force a new resource! | `bool` | `true` | no |
| <a name="input_encrypt_at_rest_kms_key_id"></a> [encrypt_at_rest_kms_key_id](#input_encrypt_at_rest_kms_key_id) | The KMS key id to encrypt the OpenSearch domain with. If not specified then it defaults to using the `aws/es` service KMS key | `string` | `null` | no |
| <a name="input_endpoint_enforce_https"></a> [endpoint_enforce_https](#input_endpoint_enforce_https) | Whether or not to require HTTPS | `bool` | `true` | no |
| <a name="input_endpoint_tls_security_policy"></a> [endpoint_tls_security_policy](#input_endpoint_tls_security_policy) | The name of the TLS security policy that needs to be applied to the HTTPS endpoint. Valid values: `Policy-Min-TLS-1-0-2019-07` and `Policy-Min-TLS-1-2-2019-07` | `string` | `"Policy-Min-TLS-1-2-2019-07"` | no |
| <a name="input_ephemeral_list"></a> [ephemeral_list](#input_ephemeral_list) | m3 and r3 are supported by aws using ephemeral storage but are a legacy instance type | `list(string)` | <pre>[<br>  "i3.large.search",<br>  "i3.xlarge.search",<br>  "i3.2xlarge.search",<br>  "i3.4xlarge.search",<br>  "i3.8xlarge.search",<br>  "i3.16xlarge.search",<br>  "r6gd.large.search",<br>  "r6gd.xlarge.search",<br>  "r6gd.2xlarge.search",<br>  "r6gd.4xlarge.search",<br>  "r6gd.8xlarge.search",<br>  "r6gd.12xlarge.search",<br>  "r6gd.16xlarge.search",<br>  "i3.large.elasticsearch",<br>  "i3.xlarge.elasticsearch",<br>  "i3.2xlarge.elasticsearch",<br>  "i3.4xlarge.elasticsearch",<br>  "i3.8xlarge.elasticsearch",<br>  "i3.16xlarge.elasticsearch",<br>  "r6gd.large.elasticsearch",<br>  "r6gd.xlarge.elasticsearch",<br>  "r6gd.2xlarge.elasticsearch",<br>  "r6gd.4xlarge.elasticsearch",<br>  "r6gd.8xlarge.elasticsearch",<br>  "r6gd.12xlarge.elasticsearch",<br>  "r6gd.16xlarge.elasticsearch"<br>]</pre> | no |
| <a name="input_instance_count"></a> [instance_count](#input_instance_count) | Size of the OpenSearch domain | `number` | `1` | no |
| <a name="input_logging_enabled"></a> [logging_enabled](#input_logging_enabled) | Whether to enable OpenSearch slow logs (index & search) in Cloudwatch | `bool` | `false` | no |
| <a name="input_logging_retention"></a> [logging_retention](#input_logging_retention) | How many days to retain OpenSearch logs in Cloudwatch | `number` | `30` | no |
| <a name="input_node_to_node_encryption"></a> [node_to_node_encryption](#input_node_to_node_encryption) | Whether to enable node-to-node encryption. Changing this on an existing cluster will force a new resource! | `bool` | `true` | no |
| <a name="input_options_indices_fielddata_cache_size"></a> [options_indices_fielddata_cache_size](#input_options_indices_fielddata_cache_size) | Sets the `indices.fielddata.cache.size` advanced option. Specifies the percentage of heap space that is allocated to fielddata | `number` | `null` | no |
| <a name="input_options_indices_query_bool_max_clause_count"></a> [options_indices_query_bool_max_clause_count](#input_options_indices_query_bool_max_clause_count) | Sets the `indices.query.bool.max_clause_count` advanced option. Specifies the maximum number of allowed boolean clauses in a query | `number` | `1024` | no |
| <a name="input_options_override_main_response_version"></a> [options_override_main_response_version](#input_options_override_main_response_version) | Whether to enable compatibility mode when creating an OpenSearch domain. Because certain Elasticsearch OSS clients and plugins check the cluster version before connecting, compatibility mode sets OpenSearch to report its version as 7.10 so these clients continue to work | `bool` | `true` | no |
| <a name="input_options_rest_action_multi_allow_explicit_index"></a> [options_rest_action_multi_allow_explicit_index](#input_options_rest_action_multi_allow_explicit_index) | Sets the `rest.action.multi.allow_explicit_index` advanced option. When set to `false`, OpenSearch will reject requests that have an explicit index specified in the request body | `bool` | `true` | no |
| <a name="input_search_version"></a> [search_version](#input_search_version) | Version of the OpenSearch domain | `string` | `"OpenSearch_1.1"` | no |
| <a name="input_security_group_ids"></a> [security_group_ids](#input_security_group_ids) | Extra security group IDs to attach to the OpenSearch domain. Note: a default SG is already created and exposed via outputs | `list(string)` | `[]` | no |
| <a name="input_snapshot_start_hour"></a> [snapshot_start_hour](#input_snapshot_start_hour) | Hour during which an automated daily snapshot is taken of the OpenSearch indices | `number` | `3` | no |
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids) | Required if vpc_id is specified: Subnet IDs for the VPC enabled OpenSearch domain endpoints to be created in | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_volume_iops"></a> [volume_iops](#input_volume_iops) | Required if volume_type="io1" or "gp3": Amount of provisioned IOPS for the EBS volume | `number` | `0` | no |
| <a name="input_volume_type"></a> [volume_type](#input_volume_type) | EBS volume type to use for the OpenSearch domain | `string` | `"gp2"` | no |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | VPC ID where to deploy the OpenSearch domain. If set, you also need to specify `subnet_ids`. If not set, the module creates a public domain | `string` | `null` | no |
| <a name="input_warm_count"></a> [warm_count](#input_warm_count) | Number of warm nodes (2 - 150) | `number` | `2` | no |
| <a name="input_warm_enabled"></a> [warm_enabled](#input_warm_enabled) | Whether to enable warm storage | `bool` | `false` | no |
| <a name="input_warm_type"></a> [warm_type](#input_warm_type) | Instance type of the warm nodes | `string` | `"ultrawarm1.medium.search"` | no |
| <a name="input_zone_awareness_enabled"></a> [zone_awareness_enabled](#input_zone_awareness_enabled) | Whether to enable zone_awareness or not, if not set, multi az is enabled by default and configured through number of instances/subnets available | `bool` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output_arn) | ARN of the OpenSearch domain |
| <a name="output_domain_id"></a> [domain_id](#output_domain_id) | ID of the OpenSearch domain |
| <a name="output_domain_name"></a> [domain_name](#output_domain_name) | Name of the OpenSearch domain |
| <a name="output_domain_region"></a> [domain_region](#output_domain_region) | Region of the OpenSearch domain |
| <a name="output_endpoint"></a> [endpoint](#output_endpoint) | DNS endpoint of the OpenSearch domain |
| <a name="output_kibana_endpoint"></a> [kibana_endpoint](#output_kibana_endpoint) | DNS endpoint of Kibana |
| <a name="output_sg_id"></a> [sg_id](#output_sg_id) | ID of the OpenSearch security group |

### Example

```terraform
module "opensearch" {
  source = "github.com/skyscrapers/terraform-opensearch//opensearch?ref=11.0.0"

  name           = "logs-${terraform.workspace}-es"
  instance_count = 3
  instance_type  = "m5.large.elasticsearch"
  volume_size    = 100
  vpc_id         = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids     = data.terraform_remote_state.networking.outputs.private_db_subnets
}

data "aws_iam_policy_document" "opensearch" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_user.es_user.arn}"]
    }

    actions   = ["es:*"]
    resources = ["${module.elasticsearch.arn}/*"]
  }
}

resource "aws_elasticsearch_domain_policy" "opensearch" {
  domain_name     = module.opensearch.domain_name
  access_policies = data.aws_iam_policy_document.opensearch.json
}
```

### Logging

This module by default creates Cloudwatch Log Groups & IAM permissions for ElasticSearch slow logging (search & index), but we don't enable these logs by default. You can control logging behavior via the `logging_enabled` and `logging_retention` parameters. When enabling this, make sure you also enable this on Elasticsearch side, following the [AWS documentation](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-createdomain-configure-slow-logs.html).

You can also enable Elasticsearch error logs via `application_logging_enabled = true`.

### Monitoring

For a CloudWatch based solution, check out our [`terraform-cloudwatch` modules](https://github.com/skyscrapers/terraform-cloudwatch).

For a Kubernetes & Prometheus based solution, see the [`elasticsearch_k8s_monitoring` module](#elasticsearch_k8s_monitoring) below.

### NOTES

This module will not work without the ES default role [AWSServiceRoleForAmazonElasticsearchService](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/slr-es.html). This service role needs to be created per-account so you will need to add it if not present (just once per AWS account).

Here is a code sample you can use:

```terraform
resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}
```

## opensearch-backup

This module can be used to create your own snapshots of Opensearch to S3, using [Snapshot Management](https://opensearch.org/docs/latest/tuning-your-cluster/availability-and-recovery/snapshots/snapshot-management/). It can also deploy a [PrometheusRule](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1.PrometheusRule) for monitoring snapshot success.

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3.9, < 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement_kubernetes) | ~> 2.23 |
| <a name="requirement_opensearch"></a> [opensearch](#requirement_opensearch) | ~> 2.2 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 5.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider_kubernetes) | ~> 2.23 |
| <a name="provider_opensearch"></a> [opensearch](#provider_opensearch) | ~> 2.2 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_snapshot"></a> [s3_snapshot](#module_s3_snapshot) | terraform-aws-modules/s3-bucket/aws | ~> 3.15 |

### Resources

| Name | Type |
|------|------|
| [aws_iam_role.snapshot_create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.snapshot_create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [kubernetes_manifest.prometheusrule](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [opensearch_sm_policy.snapshot](https://registry.terraform.io/providers/opensearch-project/opensearch/latest/docs/resources/sm_policy) | resource |
| [opensearch_snapshot_repository.repo](https://registry.terraform.io/providers/opensearch-project/opensearch/latest/docs/resources/snapshot_repository) | resource |
| [aws_iam_policy_document.s3_snapshot_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.snapshot_create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.snapshot_create_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input_name) | Name for the snapshot system, S3 bucket, etc. | `string` | n/a | yes |
| <a name="input_aws_kms_key_arn"></a> [aws_kms_key_arn](#input_aws_kms_key_arn) | ARN of the CMK used for S3 Server Side Encryption. When specified, we'll use the `aws:kms` SSE algorithm. When not specified, falls back to using `AES256` | `string` | `null` | no |
| <a name="input_create_cron_expression"></a> [create_cron_expression](#input_create_cron_expression) | The cron schedule used to create snapshots | `string` | `"0 0 * * *"` | no |
| <a name="input_create_time_limit"></a> [create_time_limit](#input_create_time_limit) | Sets the maximum time to wait for snapshot creation to finish. If time_limit is longer than the scheduled time interval for taking snapshots, no scheduled snapshots are taken until time_limit elapses. For example, if time_limit is set to 35 minutes and snapshots are taken every 30 minutes starting at midnight, the snapshots at 00:00 and 01:00 are taken, but the snapshot at 00:30 is skipped | `string` | `"1h"` | no |
| <a name="input_custom_sm_policy"></a> [custom_sm_policy](#input_custom_sm_policy) | Set this variable when you want to override the generated SM policy JSON with your own. Make sure to correctly set `snapshot_config.repository` to the same value as `var.name` (the bucket name) | `string` | `null` | no |
| <a name="input_delete_cron_expression"></a> [delete_cron_expression](#input_delete_cron_expression) | The cron schedule used to delete snapshots | `string` | `"0 2 * * *"` | no |
| <a name="input_delete_time_limit"></a> [delete_time_limit](#input_delete_time_limit) | Sets the maximum time to wait for snapshot deletion to finish | `string` | `"1h"` | no |
| <a name="input_indices"></a> [indices](#input_indices) | The names of the indexes in the snapshot. Multiple index names are separated by `,`. Supports wildcards (`*`) | `string` | `"*"` | no |
| <a name="input_max_age"></a> [max_age](#input_max_age) | The maximum time a snapshot is retained in S3 | `string` | `"14d"` | no |
| <a name="input_max_count"></a> [max_count](#input_max_count) | The maximum number of snapshots retained in S3 | `number` | `400` | no |
| <a name="input_min_count"></a> [min_count](#input_min_count) | The minimum number of snapshot retained in S3 | `number` | `1` | no |
| <a name="input_prometheusrule_alert_labels"></a> [prometheusrule_alert_labels](#input_prometheusrule_alert_labels) | Additional labels to add to the PrometheusRule alert | `map(string)` | `{}` | no |
| <a name="input_prometheusrule_enabled"></a> [prometheusrule_enabled](#input_prometheusrule_enabled) | Whether to deploy a [PrometheusRule](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1.PrometheusRule) for monitoring the snapshots. Requires the [prometheus-operator](https://prometheus-operator.dev/) and [elasticsearch-exporter](https://github.com/prometheus-community/elasticsearch_exporter) to be deployed | `bool` | `true` | no |
| <a name="input_prometheusrule_labels"></a> [prometheusrule_labels](#input_prometheusrule_labels) | Additional K8s labels to add to the PrometheusRule | `map(string)` | <pre>{<br>  "prometheus": "opensearch-backup"<br>}</pre> | no |
| <a name="input_prometheusrule_namespace"></a> [prometheusrule_namespace](#input_prometheusrule_namespace) | Namespace where to deploy the PrometheusRule | `string` | `"infrastructure"` | no |
| <a name="input_prometheusrule_query_period"></a> [prometheusrule_query_period](#input_prometheusrule_query_period) | Period to apply to the PrometheusRule queries. Make sure this is bigger than the `create_cron_expression` interval | `string` | `"32h"` | no |
| <a name="input_prometheusrule_severity"></a> [prometheusrule_severity](#input_prometheusrule_severity) | Severity of the PrometheusRule alert. Usual values are: `info`, `warning` and `critical` | `string` | `"warning"` | no |
| <a name="input_s3_force_destroy"></a> [s3_force_destroy](#input_s3_force_destroy) | Whether to force-destroy and empty the S3 bucket when destroying this Terraform module. WARNING: Not recommended! | `bool` | `false` | no |
| <a name="input_s3_replication_configuration"></a> [s3_replication_configuration](#input_s3_replication_configuration) | Replication configuration block for the S3 bucket. See <https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/v3.15.1/examples/s3-replication> for an example | `any` | `{}` | no |

### Outputs

No outputs.

### Example

```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    opensearch = {
      source = "opensearch-project/opensearch"
    }
  }
}

provider "opensearch" {
  url                 = module.opensearch.endpoint
  aws_region          = var._aws_provider_region
  aws_profile         = var._aws_provider_profile
  aws_assume_role_arn = "arn:aws:iam::${var._aws_provider_account_id}:role/${var._aws_provider_assume_role}"
}

module "opensearch_snapshots" {
  source = "github.com/skyscrapers/terraform-opensearch//opensearch-backup?ref=11.0.0"
  name   = "${module.opensearch.domain_name}-snapshots"
}
```

## elasticsearch_k8s_monitoring

This module deploys our [`elasticsearch/monitoring`](https://github.com/skyscrapers/charts/elasticsearch-monitoring) chart on Kubernetes.

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3.9, < 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement_helm) | ~> 2.11 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement_kubernetes) | ~> 2.23 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider_helm) | ~> 2.11 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [helm_release.elasticsearch_monitoring](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_exporter_role_arn"></a> [cloudwatch_exporter_role_arn](#input_cloudwatch_exporter_role_arn) | IAM role ARN to use for the CloudWatch exporter. Used via either IRSA or kube2iam (see `var.irsa_enabled`) | `string` | n/a | yes |
| <a name="input_elasticsearch_domain_name"></a> [elasticsearch_domain_name](#input_elasticsearch_domain_name) | Domain name of the AWS Elasticsearch domain | `string` | n/a | yes |
| <a name="input_elasticsearch_domain_region"></a> [elasticsearch_domain_region](#input_elasticsearch_domain_region) | Region of the AWS Elasticsearch domain | `string` | n/a | yes |
| <a name="input_elasticsearch_endpoint"></a> [elasticsearch_endpoint](#input_elasticsearch_endpoint) | Endpoint of the AWS Elasticsearch domain | `string` | n/a | yes |
| <a name="input_kubernetes_namespace"></a> [kubernetes_namespace](#input_kubernetes_namespace) | Kubernetes namespace where to deploy the `skyscrapers/elasticsearch-monitoring` chart | `string` | n/a | yes |
| <a name="input_cw_exporter_memory"></a> [cw_exporter_memory](#input_cw_exporter_memory) | Memory request and limit for the prometheus-cloudwatch-exporter pod | `string` | `"160Mi"` | no |
| <a name="input_elasticsearch_monitoring_chart_version"></a> [elasticsearch_monitoring_chart_version](#input_elasticsearch_monitoring_chart_version) | elasticsearch-monitoring Helm chart version to deploy | `string` | `"1.11.2"` | no |
| <a name="input_es_exporter_memory"></a> [es_exporter_memory](#input_es_exporter_memory) | Memory request and limit for the prometheus-elasticsearch-exporter pod | `string` | `"48Mi"` | no |
| <a name="input_force_helm_update"></a> [force_helm_update](#input_force_helm_update) | Modify this variable to trigger an update on all Helm charts (you can set any value). Due to current limitations of the Helm provider, it doesn't detect drift on the deployed values | `string` | `"1"` | no |
| <a name="input_irsa_enabled"></a> [irsa_enabled](#input_irsa_enabled) | Whether to use [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html). When `true`, the Cloudwatch exporter's SA is appropriately annotated. If `false` a [kube2iam](https://github.com/jtblin/kube2iam) Pod annotation is set instead | `bool` | `true` | no |
| <a name="input_sla"></a> [sla](#input_sla) | SLA of the monitored Elasticsearch cluster. Will default to the k8s cluster SLA if omited | `string` | `null` | no |
| <a name="input_system_nodeSelector"></a> [system_nodeSelector](#input_system_nodeSelector) | nodeSelector to add to the kubernetes pods. Set to null to disable. | `map(map(string))` | <pre>{<br>  "nodeSelector": {<br>    "role": "system"<br>  }<br>}</pre> | no |
| <a name="input_system_tolerations"></a> [system_tolerations](#input_system_tolerations) | Tolerations to add to the kubernetes pods. Set to null to disable. | `any` | <pre>{<br>  "tolerations": [<br>    {<br>      "effect": "NoSchedule",<br>      "key": "role",<br>      "operator": "Equal",<br>      "value": "system"<br>    }<br>  ]<br>}</pre> | no |

### Outputs

No outputs.

## kibana_k8s_auth_ingress

This module deploys an Ingress with [external authentication](https://kubernetes.github.io/ingress-nginx/examples/auth/oauth-external-auth/) on Kubernetes to reach the AWS Elasticsearch Kibana endpoint.

### Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

### Providers

| Name | Version |
|------|---------|
| kubernetes | n/a |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| elasticsearch_domain_name | Domain name of the AWS Elasticsearch domain | `string` | n/a | yes |
| elasticsearch_endpoint | Endpoint of the AWS Elasticsearch domain | `string` | n/a | yes |
| ingress_auth_signin | Value to set for the `nginx.ingress.kubernetes.io/auth-signin` annotation | `string` | n/a | yes |
| ingress_auth_url | Value to set for the `nginx.ingress.kubernetes.io/auth-url` annotation | `string` | n/a | yes |
| ingress_host | Hostname to use for the Ingress | `string` | n/a | yes |
| kubernetes_namespace | Kubernetes namespace where to deploy the Ingress | `string` | n/a | yes |
| ingress_configuration_snippet | Value to set for the `nginx.ingress.kubernetes.io/configuration-snippet` annotation | `string` | `null` | no |

### Outputs

No output.

## kibana_k8s_auth_proxy

**This module is no longer maintained!**

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

## Upgrading

### Version 10.0.0 to 11.0.0

We removed the custom S3 backup mechanism (via Lambda) from the `opensearch` module. As an alternative we now offer a new `opensearch-backup` module, which relies on the OpenSearch [Snapshot Management API](https://opensearch.org/docs/latest/tuning-your-cluster/availability-and-recovery/snapshots/sm-api) to create snapshots to S3.

If you want to upgrade, without destroying your old S3 snapshot bucket, we recommend to remove the bucket from Terraform's state:

```hcl
terraform state rm aws_s3_bucket.snapshot[0]
```

If you wish to import the old bucket into the new module, you can run:

```hcl
terraform import module.s3_snapshot.aws_s3_bucket.this "<opensearch_domain_name>-snapshot"
```

Also make sure to set `var.name` of this module to `<opensearch_domain_name>-snapshot`.

Alternatively you can just let the module create a new bucket.

### Version 9.1.4 to 10.0.0

In the `elasticsearch_k8s_monitoring` module, the variables `system_tolerations` and `system_nodeSelector` have been added to isolate the monitoring on a dedicated system node pool. If you don't want this you can override these variables to `null` to disable.

### Version 8.0.0 to 8.2.0

In the `opensearch` module, the `s3_snapshots_schedule_expression` variable has been replaced with `s3_snapshots_schedule_period`. Instead of a cron expression, we only allow to specify a period in hours, which will be used as a `rate(x hours)`.

### Version 7.0.0 to 8.0.0

This change migrates the `elasticsearch` module to `opensearch`. This is mostly a cosmetic change, however there's several breaking things to note:

- Security Group description is updated, which would normally trigger a destroy/recreate. However existing setups won't be affected due to an ignore lifecycle
- Variables `project` and `environment` have been removed. Only the `name` variable is now used. For existing setups, you can set `name = "<myproject>-<myenvironment>-<oldname>"` to retain the original "name".
- CloudWatch Log Groups will be destroyed and recreated using the new name. If you wish to keep your older logs, it's best to remove the existing Log Groups from the TF state:

```shell
terraform state rm module.elasticsearch.aws_cloudwatch_log_group.cwl_index
terraform state rm module.elasticsearch.aws_cloudwatch_log_group.cwl_search
terraform state rm module.elasticsearch.aws_cloudwatch_log_group.cwl_application
```

- Variable `elasticsearch_version` has been renamed to `search_version`, with default value `OpenSearch_1.1`
- We no longer merge the `tags` variable with our own hardcoded defaults (`Environment`, `Project`, `Name`) , all tags need to be passed through the `tags` variable and/or through the `default_tags` provider setting
- Updated list of instance types with NVMe SSD storage

### Version 6.0.0 to 7.0.0

Behavior of this module in function of backups has changed much between versions 6.0.0 and 7.0.0:

- Replace the `snapshot_bucket_enabled` variable with `s3_snapshots_enabled`
  - Note: This will also enable the Lambda for automated backups
  - If you just want to keep the bucket, you can remove it from the terraform state and manage it outside the module: `terraform state rm aws_s3_bucket.snapshot[0]`
- The IAM role for taking snapshots has been renamed. If you want to keep the old role too, you should remove it from the terraform state: `terraform state rm module.registrations.aws_iam_role.role[0]`
  - Otherwise just let it destroy the old role and it will create a new one

Also note that some default values for variables has beem changed, mostly related to encryption. If this triggers an unwanted change, you can override this by explicitly setting the variable with it's old value.
