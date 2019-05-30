# terraform-awselasticsearch

Terraform module to setup all resources needed for setting up an AWS Elasticsearch Service domain.

## awselasticseacrh

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cognito\_enabled | Bool(optional, false): Whether to enable Cognito for authentication in Kibana | string | `"false"` | no |
| cognito\_identity\_pool\_id | String(required when cognito_enabled is enabled) ID of the Cognito Identity Pool to use | string | `""` | no |
| cognito\_role\_arn | String(required when cognito_enabled is enabled) ARN of the IAM role that has the AmazonESCognitoAccess policy attached | string | `""` | no |
| cognito\_user\_pool\_id | String(required when cognito_enabled is enabled) ID of the Cognito User Pool to use | string | `""` | no |
| dedicated\_master\_count | Int(optional, 1): Number of dedicated master nodes in the domain | string | `"1"` | no |
| dedicated\_master\_enabled | Bool(optional, false): Whether dedicated master nodes are enabled for the domain | string | `"false"` | no |
| dedicated\_master\_type | String(optional, t2.small.elasticsearch): Instance type of the dedicated master nodes in the domain | string | `"t2.small.elasticsearch"` | no |
| disable\_encrypt\_at\_rest | Bool(optional, false): Whether to force-disable encryption at rest, overriding the default to enable encryption if it is supported by the chosen `instance_type`. If you want to keep encryption disabled on an `instance_type` that is compatible with encryption you need to set this parameter to `true`. This is especially important for existing Amazon ES clusters, since enabling/disabling encryption at rest will destroy your cluster! | string | `"false"` | no |
| elasticsearch\_version | String(optional, "6.3": Version of the Elasticsearch domain | string | `"6.3"` | no |
| encryption\_list | List all instances which support encryption at resthttps://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/aes-supported-instance-types.html | list | `<list>` | no |
| environment | String(required): Environment name | string | n/a | yes |
| ephemeral\_list | m3 and r3 are supported by aws using ephemeral storage but are a lecacy instance type | list | `<list>` | no |
| instance\_count | Int(optional, 1): Size of the Elasticsearch domain | string | `"1"` | no |
| instance\_type | String(optional, t2.small.elasticsearch): Instance type to use for the Elasticsearch domain | string | `"t2.small.elasticsearch"` | no |
| logging\_enabled | Bool(optional, false): Whether to enable Elasticsearch slow logs in Cloudwatch | string | `"false"` | no |
| logging\_retention | Int(optional, 30): How many days to retain Elasticsearch logs in Cloudwatch | string | `"30"` | no |
| name | String(optional, "es"): Name to use for the Elasticsearch domain | string | n/a | yes |
| options\_indices\_fielddata\_cache\_size | String(optional, ""): Sets the `indices.fielddata.cache.size` advanced option. Specifies the percentage of heap space that is allocated to fielddata | string | `""` | no |
| options\_indices\_query\_bool\_max\_clause\_count | String(optional, "1024"): Sets the `indices.query.bool.max_clause_count` advanced option. Specifies the maximum number of allowed boolean clauses in a query | string | `"1024"` | no |
| options\_rest\_action\_multi\_allow\_explicit\_index | Bool(optional, "true"): Sets the `rest.action.multi.allow_explicit_index` advanced option (must be string, not bool!). If you want to configure access to domain sub-resources, such as specific indices, you must set this property to "false". Setting this property to "false" prevents users from bypassing access control for sub-resources | string | `"true"` | no |
| project | String(required): Project name | string | n/a | yes |
| security\_group\_ids | List(optional): Extra security group IDs to attach to the Elasticsearch domain. Note: a default SG is already created and exposed via outputs | list | `<list>` | no |
| snapshot\_bucket\_enabled | Bool(optional, false): Whether to create a bucket for custom Elasticsearch backups (other than the default daily one) | string | `"false"` | no |
| snapshot\_start\_hour | Int(optional, 3): Hour during which an automated daily snapshot is taken of the Elasticsearch indices | string | `"3"` | no |
| subnet\_ids | List(required if vpc_id is specified): Subnet IDs for the VPC enabled Elasticsearch domain endpoints to be created in | list | `<list>` | no |
| volume\_iops | Int(required if volume_type="io1"): Amount of provisioned IOPS for the EBS volume | string | `"0"` | no |
| volume\_size | Int(required): EBS volume size (in GB) to use for the Elasticsearch domain | string | n/a | yes |
| volume\_type | String(optional, "gp2"): EBS volume type to use for the Elasticsearch domain | string | `"gp2"` | no |
| vpc\_id | String(optional): VPC ID where to deploy the Elasticsearch domain. If set, you also need to specify `subnet_ids`. If not set, the module creates a public domain | string | `""` | no |
| zone\_awareness\_enabled | Bool(optional, false): Whether to enable zone_awareness or not | string | `"false"` | no |

## Outputs

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
  source                   = "github.com/skyscrapers/terraform-awselasticsearch?ref=2.0"
  name                     = "es"
  project                  = "${var.project}"
  environment              = "${terraform.workspace}"
  version                  = "5.5"
  instance_count           = 2
  instance_type            = "t2.medium.elasticsearch"
  volume_size              = 100
  vpc_id                   = "${data.terraform_remote_state.static.vpc_id}"
  subnet_ids               = ["${slice(data.terraform_remote_state.static.db_subnets,0,var.es_instance_count)}"]
  dedicated_master_enabled = false
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

## Backups

The AWS Elasticsearch Service handles backups automatically via daily snapshots. You can control when this happens by setting `snapshot_start_hour`.

It's possible to create a custom backup schedule by using the normal Elasticsearch API for snapshotting. This module can create an S3 bucket and IAM role allowing such scenario's (`snapshot_bucket_enabled = true`). More info on how to create custom snapshots can be found in the [AWS documentation](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-managedomains-snapshots.html).

## Logging

This module by default creates Cloudwatch Log Groups & IAM permissions for ElasticSearch slow logging, but we don't enable these logs by default. You can control logging behavior via the `logging_enabled` and `logging_retention` parameters. When enabling this, make sure you also enable this on Elasticsearch side, following the [AWS documentation](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-createupdatedomains.html#es-createdomain-configure-slow-logs).

## Monitoring

This module generates a Helm values file which can be used for the [`elasticsearch/monitoring`](https://github.com/skyscrapers/charts/elasticsearch-monitoring) chart.

The file, `helm_values.yaml` needs to be created in the same folder as the Terraform code that is calling this module.

## NOTES

This module will not work without the ES default role [AWSServiceRoleForAmazonElasticsearchService](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/slr-es.html). This service role needs to be created per-account so you will need to add it to the `general` stack if not present. 

Here is a code sample you can use:
```
resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}
```
