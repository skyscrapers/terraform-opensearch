# terraform-awselasticsearch

- [terraform-awselasticsearch](#terraform-awselasticsearch)
  - [elasticsearch](#elasticsearch)
    - [Requirements](#requirements)
    - [Providers](#providers)
    - [Inputs](#inputs)
    - [Outputs](#outputs)
    - [Example](#example)
    - [Backups](#backups)
    - [Logging](#logging)
    - [Monitoring](#monitoring)
    - [NOTES](#notes)
  - [elasticsearch_k8s_monitoring](#elasticsearch_k8s_monitoring)
    - [Requirements](#requirements-1)
    - [Providers](#providers-1)
    - [Inputs](#inputs-1)
    - [Outputs](#outputs-1)
  - [kibana_k8s_auth_ingress](#kibana_k8s_auth_ingress)
    - [Requirements](#requirements-2)
    - [Providers](#providers-2)
    - [Inputs](#inputs-2)
    - [Outputs](#outputs-2)
  - [kibana_k8s_auth_proxy](#kibana_k8s_auth_proxy)
    - [Inputs](#inputs-3)
    - [Outputs](#outputs-3)
  - [Upgrading](#upgrading)
    - [Version 6.0.0 to 7.0.0](#version-600-to-700)

## elasticsearch

Terraform module to setup all resources needed for setting up an AWS Elasticsearch Service domain.

### Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |

### Providers

| Name | Version |
|------|---------|
| aws | n/a |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| instance_type | Instance type to use for the Elasticsearch domain | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| volume_size | EBS volume size (in GB) to use for the Elasticsearch domain | `number` | n/a | yes |
| application_logging_enabled | Whether to enable Elasticsearch application logs (error) in Cloudwatch | `bool` | `false` | no |
| availability_zone_count | Number of Availability Zones for the domain to use with zone_awareness_enabled.Valid values: 2 or 3. Automatically configured through number of instances/subnets available if not set. | `number` | `null` | no |
| cognito_enabled | Whether to enable Cognito for authentication in Kibana | `bool` | `false` | no |
| cognito_identity_pool_id | Required when cognito_enabled is enabled: ID of the Cognito Identity Pool to use | `string` | `null` | no |
| cognito_role_arn | Required when `cognito_enabled` is enabled: ARN of the IAM role that has the AmazonESCognitoAccess policy attached | `string` | `null` | no |
| cognito_user_pool_id | Required when cognito_enabled is enabled: ID of the Cognito User Pool to use | `string` | `null` | no |
| custom_endpoint | The domain name to use as custom endpoint for Elasicsearch | `string` | `null` | no |
| custom_endpoint_certificate_arn | ARN of the ACM certificate to use for the custom endpoint. Required when custom endpoint is set along with enabling `endpoint_enforce_https` | `string` | `null` | no |
| dedicated_master_count | Number of dedicated master nodes in the domain (can be 3 or 5) | `number` | `3` | no |
| dedicated_master_enabled | Whether dedicated master nodes are enabled for the domain. Automatically enabled when `warm_enabled = true` | `bool` | `false` | no |
| dedicated_master_type | Instance type of the dedicated master nodes in the domain | `string` | `"t3.small.elasticsearch"` | no |
| elasticsearch_version | Version of the Elasticsearch domain | `string` | `"7.9"` | no |
| encrypt_at_rest | Whether to enable encryption at rest for the cluster. Changing this on an existing cluster will force a new resource! | `bool` | `true` | no |
| encrypt_at_rest_kms_key_id | The KMS key id to encrypt the Elasticsearch domain with. If not specified then it defaults to using the `aws/es` service KMS key | `string` | `null` | no |
| endpoint_enforce_https | Whether or not to require HTTPS | `bool` | `true` | no |
| endpoint_tls_security_policy | The name of the TLS security policy that needs to be applied to the HTTPS endpoint. Valid values: `Policy-Min-TLS-1-0-2019-07` and `Policy-Min-TLS-1-2-2019-07` | `string` | `"Policy-Min-TLS-1-2-2019-07"` | no |
| ephemeral_list | m3 and r3 are supported by aws using ephemeral storage but are a legacy instance type | `list(string)` | <pre>[<br>  "i2.xlarge.elasticsearch",<br>  "i2.2xlarge.elasticsearch",<br>  "i3.large.elasticsearch",<br>  "i3.xlarge.elasticsearch",<br>  "i3.2xlarge.elasticsearch",<br>  "i3.4xlarge.elasticsearch",<br>  "i3.8xlarge.elasticsearch",<br>  "i3.16xlarge.elasticsearch"<br>]</pre> | no |
| instance_count | Size of the Elasticsearch domain | `number` | `1` | no |
| logging_enabled | Whether to enable Elasticsearch slow logs (index & search) in Cloudwatch | `bool` | `false` | no |
| logging_retention | How many days to retain Elasticsearch logs in Cloudwatch | `number` | `30` | no |
| name | Name to use for the Elasticsearch domain | `string` | `"es"` | no |
| node_to_node_encryption | Whether to enable node-to-node encryption. Changing this on an existing cluster will force a new resource! | `bool` | `true` | no |
| options_indices_fielddata_cache_size | Sets the `indices.fielddata.cache.size` advanced option. Specifies the percentage of heap space that is allocated to fielddata | `number` | `null` | no |
| options_indices_query_bool_max_clause_count | Sets the `indices.query.bool.max_clause_count` advanced option. Specifies the maximum number of allowed boolean clauses in a query | `number` | `1024` | no |
| options_rest_action_multi_allow_explicit_index | Sets the `rest.action.multi.allow_explicit_index` advanced option. When set to `false`, Elasticsearch will reject requests that have an explicit index specified in the request body | `bool` | `true` | no |
| s3_snapshots_enabled | Whether to create a custom snapshot S3 bucket and enable automated snapshots through Lambda | `bool` | `false` | no |
| s3_snapshots_lambda_timeout | The execution timeout for the S3 snapshotting Lambda function | `number` | `180` | no |
| s3_snapshots_logs_retention | How many days to retain logs for the S3 snapshot Lambda function | `number` | `30` | no |
| s3_snapshots_monitoring_sns_topic_arn | ARN for the SNS Topic to send alerts to from the S3 snapshot Lambda function. Enables monitoring of the Lambda function | `string` | `null` | no |
| s3_snapshots_retention | How many days to retain the Elasticsearch snapshots in S3 | `number` | `14` | no |
| s3_snapshots_schedule_expression | The scheduling expression for running the S3 based Elasticsearch snapshot Lambda (eg. every day at 2AM) | `string` | `"cron(0 2 * * ? *)"` | no |
| security_group_ids | Extra security group IDs to attach to the Elasticsearch domain. Note: a default SG is already created and exposed via outputs | `list(string)` | `[]` | no |
| snapshot_start_hour | Hour during which an automated daily snapshot is taken of the Elasticsearch indices | `number` | `3` | no |
| subnet_ids | Required if vpc_id is specified: Subnet IDs for the VPC enabled Elasticsearch domain endpoints to be created in | `list(string)` | `[]` | no |
| tags | Optional tags | `map(string)` | `{}` | no |
| volume_iops | Required if volume_type="io1": Amount of provisioned IOPS for the EBS volume | `number` | `0` | no |
| volume_type | EBS volume type to use for the Elasticsearch domain | `string` | `"gp2"` | no |
| vpc_id | VPC ID where to deploy the Elasticsearch domain. If set, you also need to specify `subnet_ids`. If not set, the module creates a public domain | `string` | `null` | no |
| warm_count | Number of warm nodes (2 - 150) | `number` | `2` | no |
| warm_enabled | Whether to enable warm storage | `bool` | `false` | no |
| warm_type | Instance type of the warm nodes | `string` | `"ultrawarm1.medium.elasticsearch"` | no |
| zone_awareness_enabled | Whether to enable zone_awareness or not, if not set, multi az is enabled by default and configured through number of instances/subnets available | `bool` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| arn | ARN of the Elasticsearch domain |
| domain_id | ID of the Elasticsearch domain |
| domain_name | Name of the Elasticsearch domain |
| domain_region | Region of the Elasticsearch domain |
| endpoint | DNS endpoint of the Elasticsearch domain |
| kibana_endpoint | DNS endpoint of Kibana |
| sg_id | ID of the Elasticsearch security group |

### Example

```terraform
module "elasticsearch" {
  source = "github.com/skyscrapers/terraform-awselasticsearch//elasticsearch?ref=7.0.0"

  project        = "logs"
  environment    = terraform.workspace
  instance_count = 3
  instance_type  = "m5.large.elasticsearch"
  volume_size    = 100
  vpc_id         = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids     = data.terraform_remote_state.networking.outputs.private_db_subnets

  s3_snapshots_enabled             = true
  s3_snapshots_schedule_expression = "rate(12 hours)"
  s3_snapshots_retention           = 14
}

data "aws_iam_policy_document" "elasticsearch" {
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

resource "aws_elasticsearch_domain_policy" "elasticsearch" {
  domain_name     = module.elasticsearch.domain_name
  access_policies = data.aws_iam_policy_document.elasticsearch.json
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

### Version 6.0.0 to 7.0.0

Behavior of this module in function of backups has changed much between versions 6.0.0 and 7.0.0:

- Replace the `snapshot_bucket_enabled` variable with `s3_snapshots_enabled`
  - Note: This will also enable the Lambda for automated backups
  - If you just want to keep the bucket, you can remove it from the terraform state and manage it outside the module: `terraform state rm aws_s3_bucket.snapshot[0]`
- The IAM role for taking snapshots has been renamed. If you want to keep the old role too, you should remove it from the terraform state: `terraform state rm module.registrations.aws_iam_role.role[0]`
  - Otherwise just let it destroy the old role and it will create a new one

Also note that some default values for variables has beem changed, mostly related to encryption. If this triggers an unwanted change, you can override this by explicitly setting the variable with it's old value.
