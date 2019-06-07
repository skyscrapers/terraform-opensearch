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
}

variable "elasticsearch_version" {
  type        = string
  description = "Version of the Elasticsearch domain"
  default     = "6.7"
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
  description = "Whether to enable Elasticsearch slow logs in Cloudwatch"
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
  default     = "t2.small.elasticsearch"
}

variable "dedicated_master_enabled" {
  type        = bool
  description = "Whether dedicated master nodes are enabled for the domain"
  default     = false
}

variable "zone_awareness_enabled" {
  type        = bool
  description = "Whether to enable zone_awareness or not"
  default     = false
}

variable "dedicated_master_type" {
  type        = string
  description = "Instance type of the dedicated master nodes in the domain"
  default     = "t2.small.elasticsearch"
}

variable "dedicated_master_count" {
  type        = number
  description = "Number of dedicated master nodes in the domain"
  default     = 1
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

variable "snapshot_bucket_enabled" {
  type        = bool
  description = "Whether to create a bucket for custom Elasticsearch backups (other than the default daily one)"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Optional tags"
  default     = {}
}

variable "disable_encrypt_at_rest" {
  type        = bool
  description = "Whether to force-disable encryption at rest, overriding the default to enable encryption if it is supported by the chosen `instance_type`. If you want to keep encryption disabled on an `instance_type` that is compatible with encryption you need to set this parameter to `true`. This is especially important for existing Amazon ES clusters, since enabling/disabling encryption at rest will destroy your cluster!"
  default     = false
}
