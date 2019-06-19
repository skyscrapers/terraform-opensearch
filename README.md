# terraform-awselasticsearch

## elasticsearch

Terraform module to setup all resources needed for setting up an AWS Elasticsearch Service domain.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cognito\_enabled | Whether to enable Cognito for authentication in Kibana | bool | `false` | no |
| cognito\_identity\_pool\_id | Rrequired when cognito_enabled is enabled: ID of the Cognito Identity Pool to use | string | `null` | no |
| cognito\_role\_arn | Required when cognito_enabled is enabled: ARN of the IAM role that has the AmazonESCognitoAccess policy attached | string | `null` | no |
| cognito\_user\_pool\_id | Required when cognito_enabled is enabled: ID of the Cognito User Pool to use | string | `null` | no |
| dedicated\_master\_count | Number of dedicated master nodes in the domain | number | `1` | no |
| dedicated\_master\_enabled | Whether dedicated master nodes are enabled for the domain | bool | `false` | no |
| dedicated\_master\_type | Instance type of the dedicated master nodes in the domain | string | `"t2.small.elasticsearch"` | no |
| disable\_encrypt\_at\_rest | Whether to force-disable encryption at rest, overriding the default to enable encryption if it is supported by the chosen `instance_type`. If you want to keep encryption disabled on an `instance_type` that is compatible with encryption you need to set this parameter to `true`. This is especially important for existing Amazon ES clusters, since enabling/disabling encryption at rest will destroy your cluster! | bool | `false` | no |
| elasticsearch\_version | Version of the Elasticsearch domain | string | `"6.7"` | no |
| environment | Environment name | string | n/a | yes |
| instance\_count | Size of the Elasticsearch domain | number | `1` | no |
| instance\_type | Instance type to use for the Elasticsearch domain | string | `"t2.small.elasticsearch"` | no |
| application_logging\_enabled | Whether to enable Elasticsearch appliaction logs in Cloudwatch | bool | `false` | no |
| logging\_enabled | Whether to enable Elasticsearch slow logs in Cloudwatch | bool | `false` | no |
| logging\_retention | How many days to retain Elasticsearch logs in Cloudwatch | number | `30` | no |
| name | Name to use for the Elasticsearch domain | string | n/a | yes |
| options\_indices\_fielddata\_cache\_size | Sets the `indices.fielddata.cache.size` advanced option. Specifies the percentage of heap space that is allocated to fielddata | number | `null` | no |
| options\_indices\_query\_bool\_max\_clause\_count | Sets the `indices.query.bool.max_clause_count` advanced option. Specifies the maximum number of allowed boolean clauses in a query | number | `1024` | no |
| options\_rest\_action\_multi\_allow\_explicit\_index | Sets the `rest.action.multi.allow_explicit_index` advanced option. When set to `false`, Elasticsearch will reject requests that have an explicit index specified in the request body | bool | `true` | no |
| project | Project name | string | n/a | yes |
| security\_group\_ids | Extra security group IDs to attach to the Elasticsearch domain. Note: a default SG is already created and exposed via outputs | list(string) | `[]` | no |
| snapshot\_bucket\_enabled | Whether to create a bucket for custom Elasticsearch backups (other than the default daily one) | string | `"false"` | no |
| snapshot\_start\_hour | Int(optional, 3): Hour during which an automated daily snapshot is taken of the Elasticsearch indices | number | `3` | no |
| subnet\_ids | Required if vpc_id is specified: Subnet IDs for the VPC enabled Elasticsearch domain endpoints to be created in | list(string) | `[]` | no |
| tags | Optional tags | map | `{}` | no |
| volume\_iops | Required if volume_type="io1": Amount of provisioned IOPS for the EBS volume | number | `0` | no |
| volume\_size | EBS volume size (in GB) to use for the Elasticsearch domain | number | n/a | yes |
| volume\_type | EBS volume type to use for the Elasticsearch domain | string | `"gp2"` | no |
| vpc\_id | VPC ID where to deploy the Elasticsearch domain. If set, you also need to specify `subnet_ids`. If not set, the module creates a public domain | string | `null` | no |
| zone\_awareness\_enabled | Whether to enable zone_awareness or not | bool | `false` | no |

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

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|

| elasticsearch\_monitoring\_chart\_version | elasticsearch-monitoring Helm chart version to deploy | string | `"0.2.5"` | no |
| elasticsearch\_endpoint | Endpoint of the AWS Elasticsearch domain | string | n/a | yes |
| elasticsearch\_domain\_name | Domain name of the AWS Elasticsearch domain | string | n/a | yes |
| elasticsearch\_domain\_region | Region of the AWS Elasticsearch domain | string | n/a | yes |
| kubernetes\_context | Kubeconfig context to use for deploying the `skyscrapers/elasticsearch-monitoring` chart | string | n/a | yes |
| kubernetes\_namespace | Kubernetes namespace where to deploy the `skyscrapers/elasticsearch-monitoring` chart | string | n/a | yes |
| kubernetes\_worker\_instance\_role\_arns | Role ARNs of the Kubernetes nodes to attach the kube2iam assume_role to | list(string) | n/a | yes |
| force\_helm\_update | Modify this variable to trigger an update on all Helm charts (you can set any value). Due to current limitations of the Helm provider, it doesn't detect drift on | string | `"1"` | no |

## kibana_k8s_proxy

This module deploys [keycloack-gatekeeper](https://github.com/keycloak/keycloak-gatekeeper) as OIDC proxy on Kubernetes to reach the AWS Elasticsearch Kibana endpoint.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| elasticsearch\_endpoint | Endpoint of the AWS Elasticsearch domain | string | n/a | yes |
| elasticsearch\_domain\_name | Domain name of the AWS Elasticsearch domain | string | n/a | yes |
| kubernetes\_context | Kubeconfig context to use for deploying the `skyscrapers/elasticsearch-monitoring` chart | string | n/a | yes |
| kubernetes\_namespace | Kubernetes namespace where to deploy the `skyscrapers/elasticsearch-monitoring` chart | string | n/a | yes |
| gatekeeper\_image | Docker image to use for the gatekeeper deployment | string | `"keycloak/keycloak-gatekeeper:6.0.1"` | no |
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
