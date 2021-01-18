variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "name" {
  type        = string
  description = "Name to use for the Elasticsearch domain"
  default     = "es"
}

variable "elasticsearch_version" {
  type        = string
  description = "Version of the Elasticsearch domain"
  default     = "7.9"
}

variable "options_rest_action_multi_allow_explicit_index" {
  type        = bool
  description = "Sets the `rest.action.multi.allow_explicit_index` advanced option. When set to `false`, Elasticsearch will reject requests that have an explicit index specified in the request body"
  default     = true
}

variable "options_indices_fielddata_cache_size" {
  type        = number
  description = "Sets the `indices.fielddata.cache.size` advanced option. Specifies the percentage of heap space that is allocated to fielddata"
  default     = null
}

variable "options_indices_query_bool_max_clause_count" {
  type        = number
  description = "Sets the `indices.query.bool.max_clause_count` advanced option. Specifies the maximum number of allowed boolean clauses in a query"
  default     = 1024
}

variable "cognito_enabled" {
  type        = bool
  description = "Whether to enable Cognito for authentication in Kibana"
  default     = false
}

variable "cognito_user_pool_id" {
  type        = string
  description = "Required when cognito_enabled is enabled: ID of the Cognito User Pool to use"
  default     = null
}

variable "cognito_identity_pool_id" {
  type        = string
  description = "Required when cognito_enabled is enabled: ID of the Cognito Identity Pool to use"
  default     = null
}

variable "cognito_role_arn" {
  type        = string
  description = "Required when `cognito_enabled` is enabled: ARN of the IAM role that has the AmazonESCognitoAccess policy attached"
  default     = null
}

variable "logging_enabled" {
  type        = bool
  description = "Whether to enable Elasticsearch slow logs (index & search) in Cloudwatch"
  default     = false
}

variable "application_logging_enabled" {
  type        = bool
  description = "Whether to enable Elasticsearch application logs (error) in Cloudwatch"
  default     = false
}

variable "logging_retention" {
  type        = number
  description = "How many days to retain Elasticsearch logs in Cloudwatch"
  default     = 30
}

variable "instance_count" {
  type        = number
  description = "Size of the Elasticsearch domain"
  default     = 1
}

variable "instance_type" {
  type        = string
  description = "Instance type to use for the Elasticsearch domain"
}

variable "zone_awareness_enabled" {
  type        = bool
  description = "Whether to enable zone_awareness or not, if not set, multi az is enabled by default and configured through number of instances/subnets available"
  default     = null
}

variable "availability_zone_count" {
  type        = number
  description = "Number of Availability Zones for the domain to use with zone_awareness_enabled.Valid values: 2 or 3. Automatically configured through number of instances/subnets available if not set."
  default     = null
}

variable "dedicated_master_enabled" {
  type        = bool
  description = "Whether dedicated master nodes are enabled for the domain. Automatically enabled when `warm_enabled = true`"
  default     = false
}

variable "dedicated_master_type" {
  type        = string
  description = "Instance type of the dedicated master nodes in the domain"
  default     = "t3.small.elasticsearch"
}

variable "dedicated_master_count" {
  type        = number
  description = "Number of dedicated master nodes in the domain (can be 3 or 5)"
  default     = 3
}

variable "warm_enabled" {
  type        = bool
  description = "Whether to enable warm storage"
  default     = false
}

variable "warm_type" {
  type        = string
  description = "Instance type of the warm nodes"
  default     = "ultrawarm1.medium.elasticsearch"
}

variable "warm_count" {
  type        = number
  description = "Number of warm nodes (2 - 150)"
  default     = 2
}

variable "volume_type" {
  type        = string
  description = "EBS volume type to use for the Elasticsearch domain"
  default     = "gp2"
}

variable "volume_size" {
  type        = number
  description = "EBS volume size (in GB) to use for the Elasticsearch domain"
}

variable "volume_iops" {
  type        = number
  description = "Required if volume_type=\"io1\": Amount of provisioned IOPS for the EBS volume"
  default     = 0
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where to deploy the Elasticsearch domain. If set, you also need to specify `subnet_ids`. If not set, the module creates a public domain"
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "Required if vpc_id is specified: Subnet IDs for the VPC enabled Elasticsearch domain endpoints to be created in"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "Extra security group IDs to attach to the Elasticsearch domain. Note: a default SG is already created and exposed via outputs"
  default     = []
}

variable "snapshot_start_hour" {
  type        = number
  description = "Hour during which an automated daily snapshot is taken of the Elasticsearch indices"
  default     = 3
}

variable "s3_snapshots_enabled" {
  type        = bool
  description = "Whether to create a custom snapshot S3 bucket and enable automated snapshots through Lambda"
  default     = false
}

variable "s3_snapshots_schedule_expression" {
  type        = string
  description = "The scheduling expression for running the S3 based Elasticsearch snapshot Lambda (eg. every day at 2AM)"
  default     = "cron(0 2 * * ? *)"
}

variable "s3_snapshots_retention" {
  type        = number
  description = "How many days to retain the Elasticsearch snapshots in S3"
  default     = 30
}

variable "s3_snapshots_logs_retention" {
  type        = number
  description = "How many days to retain logs for the S3 snapshot Lambda function"
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Optional tags"
  default     = {}
}

variable "encrypt_at_rest" {
  type        = bool
  description = "Whether to enable encryption at rest for the cluster. Changing this on an existing cluster will force a new resource!"
  default     = true
}

variable "encrypt_at_rest_kms_key_id" {
  type        = string
  description = "The KMS key id to encrypt the Elasticsearch domain with. If not specified then it defaults to using the `aws/es` service KMS key"
  default     = null
}

variable "node_to_node_encryption" {
  type        = bool
  description = "Whether to enable node-to-node encryption. Changing this on an existing cluster will force a new resource!"
  default     = true
}

variable "endpoint_enforce_https" {
  type        = bool
  description = "Whether or not to require HTTPS"
  default     = true
}

variable "endpoint_tls_security_policy" {
  type        = string
  description = "The name of the TLS security policy that needs to be applied to the HTTPS endpoint. Valid values: `Policy-Min-TLS-1-0-2019-07` and `Policy-Min-TLS-1-2-2019-07`"
  default     = "Policy-Min-TLS-1-2-2019-07"
}
