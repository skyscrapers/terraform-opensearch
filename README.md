# terraform-awselasticsearch

- [terraform-awselasticsearch](#terraform-awselasticsearch)
  - [opensearch](#opensearch)
    - [Requirements](#requirements)
    - [Providers](#providers)
    - [Modules](#modules)
    - [Resources](#resources)
    - [Inputs](#inputs)
    - [Outputs](#outputs)
    - [Example](#example)
    - [Backups](#backups)
    - [Logging](#logging)
    - [Monitoring](#monitoring)
    - [NOTES](#notes)
  - [elasticsearch\_k8s\_monitoring](#elasticsearch_k8s_monitoring)
  - [Requirements](#requirements-1)
  - [Providers](#providers-1)
  - [Modules](#modules-1)
  - [Resources](#resources-1)
  - [Inputs](#inputs-1)
  - [Outputs](#outputs-1)
  - [kibana\_k8s\_auth\_ingress](#kibana_k8s_auth_ingress)
    - [Requirements](#requirements-2)
    - [Providers](#providers-2)
    - [Inputs](#inputs-2)
    - [Outputs](#outputs-2)
  - [kibana\_k8s\_auth\_proxy](#kibana_k8s_auth_proxy)
    - [Inputs](#inputs-3)
    - [Outputs](#outputs-3)
  - [Upgrading](#upgrading)
  - [Version 9.1.4 to 10.0.0](#version-914-to-1000)
    - [Version 8.0.0 to 8.2.0](#version-800-to-820)
    - [Version 7.0.0 to 8.0.0](#version-700-to-800)
    - [Version 6.0.0 to 7.0.0](#version-600-to-700)

## opensearch

Terraform module to setup all resources needed for setting up an AWS OpenSearch Service domain.

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_snapshot_lambda_monitoring"></a> [snapshot_lambda_monitoring](#module_snapshot_lambda_monitoring) | github.com/skyscrapers/terraform-cloudwatch//lambda_function | 2.2.0 |

### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.snapshot_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.snapshot_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.cwl_application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.cwl_index](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.cwl_search](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.snapshot_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.cwl_resource_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_elasticsearch_domain.es](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain) | resource |
| [aws_iam_role.snapshot_create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.snapshot_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.snapshot_create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.snapshot_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.snapshot_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.snapshot_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.snapshot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.snapshot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.snapshot_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.snapshot_lambda_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.snapshot_lambda_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_policy_document.cwl_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.snapshot_create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.snapshot_create_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.snapshot_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.snapshot_lambda_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
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
| <a name="input_s3_snapshots_enabled"></a> [s3_snapshots_enabled](#input_s3_snapshots_enabled) | Whether to create a custom snapshot S3 bucket and enable automated snapshots through Lambda | `bool` | `false` | no |
| <a name="input_s3_snapshots_lambda_timeout"></a> [s3_snapshots_lambda_timeout](#input_s3_snapshots_lambda_timeout) | The execution timeout for the S3 snapshotting Lambda function | `number` | `180` | no |
| <a name="input_s3_snapshots_logs_retention"></a> [s3_snapshots_logs_retention](#input_s3_snapshots_logs_retention) | How many days to retain logs for the S3 snapshot Lambda function | `number` | `30` | no |
| <a name="input_s3_snapshots_monitoring_sns_topic_arn"></a> [s3_snapshots_monitoring_sns_topic_arn](#input_s3_snapshots_monitoring_sns_topic_arn) | ARN for the SNS Topic to send alerts to from the S3 snapshot Lambda function. Enables monitoring of the Lambda function | `string` | `null` | no |
| <a name="input_s3_snapshots_retention"></a> [s3_snapshots_retention](#input_s3_snapshots_retention) | How many days to retain the OpenSearch snapshots in S3 | `number` | `14` | no |
| <a name="input_s3_snapshots_schedule_period"></a> [s3_snapshots_schedule_period](#input_s3_snapshots_schedule_period) | Snapshot frequency specified in hours | `number` | `24` | no |
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
  source = "github.com/skyscrapers/terraform-awselasticsearch//opensearch?ref=8.0.0"

  name           = "logs-${terraform.workspace}-es"
  instance_count = 3
  instance_type  = "m5.large.elasticsearch"
  volume_size    = 100
  vpc_id         = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids     = data.terraform_remote_state.networking.outputs.private_db_subnets

  s3_snapshots_enabled         = true
  s3_snapshots_schedule_period = 12
  s3_snapshots_retention       = 14
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

### Backups

**Important**: Behavior of this module in function of backups has changed much between versions 6.0.0 and 7.0.0. Make sure to read the [upgrade guide](#version-600-to-700).

The AWS Elasticsearch Service handles backups [automatically via daily (<= 5.1) or hourly (>= 5.3) snapshots](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-managedomains-snapshots.html).

Next to the built-in AWS snapshots, this module also offers creating your own backups to an S3 bucket by setting `s3_snapshots_enabled = true`. This will create an S3 bucket for storing the snapshots, a Lambda function and all required resources to automatically:

- Register the S3 bucket as snapshot repository (`s3-manual`) in Elasticsearch
- Delete (automated) snapshots in this repo that are older than `s3_snapshots_retention`
- Create a new snapshot in this repo with name `automatic-<datetime>`

Check the table above for all available `s3_snapshots_*` inputs.

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

## elasticsearch_k8s_monitoring

This module deploys our [`elasticsearch/monitoring`](https://github.com/skyscrapers/charts/elasticsearch-monitoring) chart on Kubernetes.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 4.0 |
| <a name="requirement_helm"></a> [helm](#requirement_helm) | ~> 2.5 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement_kubernetes) | ~> 2.11 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider_helm) | ~> 2.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.elasticsearch_monitoring](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_exporter_role_arn"></a> [cloudwatch_exporter_role_arn](#input_cloudwatch_exporter_role_arn) | IAM role ARN to use for the CloudWatch exporter. Used via either IRSA or kube2iam (see `var.irsa_enabled`) | `string` | n/a | yes |
| <a name="input_elasticsearch_domain_name"></a> [elasticsearch_domain_name](#input_elasticsearch_domain_name) | Domain name of the AWS Elasticsearch domain | `string` | n/a | yes |
| <a name="input_elasticsearch_domain_region"></a> [elasticsearch_domain_region](#input_elasticsearch_domain_region) | Region of the AWS Elasticsearch domain | `string` | n/a | yes |
| <a name="input_elasticsearch_endpoint"></a> [elasticsearch_endpoint](#input_elasticsearch_endpoint) | Endpoint of the AWS Elasticsearch domain | `string` | n/a | yes |
| <a name="input_kubernetes_namespace"></a> [kubernetes_namespace](#input_kubernetes_namespace) | Kubernetes namespace where to deploy the `skyscrapers/elasticsearch-monitoring` chart | `string` | n/a | yes |
| <a name="input_cw_exporter_memory"></a> [cw_exporter_memory](#input_cw_exporter_memory) | Memory request and limit for the prometheus-cloudwatch-exporter pod | `string` | `"160Mi"` | no |
| <a name="input_elasticsearch_monitoring_chart_version"></a> [elasticsearch_monitoring_chart_version](#input_elasticsearch_monitoring_chart_version) | elasticsearch-monitoring Helm chart version to deploy | `string` | `"1.11.1"` | no |
| <a name="input_es_exporter_memory"></a> [es_exporter_memory](#input_es_exporter_memory) | Memory request and limit for the prometheus-elasticsearch-exporter pod | `string` | `"48Mi"` | no |
| <a name="input_force_helm_update"></a> [force_helm_update](#input_force_helm_update) | Modify this variable to trigger an update on all Helm charts (you can set any value). Due to current limitations of the Helm provider, it doesn't detect drift on the deployed values | `string` | `"1"` | no |
| <a name="input_irsa_enabled"></a> [irsa_enabled](#input_irsa_enabled) | Whether to use [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html). When `true`, the Cloudwatch exporter's SA is appropriately annotated. If `false` a [kube2iam](https://github.com/jtblin/kube2iam) Pod annotation is set instead | `bool` | `true` | no |
| <a name="input_sla"></a> [sla](#input_sla) | SLA of the monitored Elasticsearch cluster. Will default to the k8s cluster SLA if omited | `string` | `null` | no |
| <a name="input_system_nodeSelector"></a> [system_nodeSelector](#input_system_nodeSelector) | nodeSelector to add to the kubernetes pods. Set to null to disable. | `map(map(string))` | <pre>{<br>  "nodeSelector": {<br>    "role": "system"<br>  }<br>}</pre> | no |
| <a name="input_system_tolerations"></a> [system_tolerations](#input_system_tolerations) | Tolerations to add to the kubernetes pods. Set to null to disable. | `any` | <pre>{<br>  "tolerations": [<br>    {<br>      "effect": "NoSchedule",<br>      "key": "role",<br>      "operator": "Equal",<br>      "value": "system"<br>    }<br>  ]<br>}</pre> | no |

## Outputs

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

## Version 9.1.4 to 10.0.0

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
