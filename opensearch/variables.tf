variable "name" {
  type        = string
  description = "Name to use for the OpenSearch domain"
}

variable "search_version" {
  type        = string
  description = "Version of the OpenSearch domain"
  default     = "OpenSearch_2.19"
}

variable "options_rest_action_multi_allow_explicit_index" {
  type        = bool
  description = "Sets the `rest.action.multi.allow_explicit_index` advanced option. When set to `false`, OpenSearch will reject requests that have an explicit index specified in the request body"
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
  description = "Whether to enable OpenSearch slow logs (index & search) in Cloudwatch"
  default     = false
}

variable "application_logging_enabled" {
  type        = bool
  description = "Whether to enable OpenSearch application logs (error) in Cloudwatch"
  default     = false
}

variable "logging_retention" {
  type        = number
  description = "How many days to retain OpenSearch logs in Cloudwatch"
  default     = 30
}

variable "instance_count" {
  type        = number
  description = "Size of the OpenSearch domain"
  default     = 1
}

variable "instance_type" {
  type        = string
  description = "Instance type to use for the OpenSearch domain"
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
  default     = "t3.small.search"
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
  default     = "ultrawarm1.medium.search"
}

variable "warm_count" {
  type        = number
  description = "Number of warm nodes (2 - 150)"
  default     = 2
}

variable "volume_type" {
  type        = string
  description = "EBS volume type to use for the OpenSearch domain"
  default     = "gp2"
}

variable "volume_size" {
  type        = number
  description = "EBS volume size (in GB) to use for the OpenSearch domain"
}

variable "volume_iops" {
  type        = number
  description = "Required if volume_type=\"io1\" or \"gp3\": Amount of provisioned IOPS for the EBS volume"
  default     = 0
}

variable "volume_throughput" {
  type        = number
  description = "Required if volume_type=\"gp3\": Amount of throughput in MiB/s for the EBS volume. For more information, check <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-optimized.html#current-general-purpose>"
  default     = 125
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where to deploy the OpenSearch domain. If set, you also need to specify `subnet_ids`. If not set, the module creates a public domain"
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "Required if vpc_id is specified: Subnet IDs for the VPC enabled OpenSearch domain endpoints to be created in"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "Extra security group IDs to attach to the OpenSearch domain. Note: a default SG is already created and exposed via outputs"
  default     = []
}

variable "snapshot_start_hour" {
  type        = number
  description = "Hour during which an automated daily snapshot is taken of the OpenSearch indices"
  default     = 3
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
  description = "The KMS key id to encrypt the OpenSearch domain with. If not specified then it defaults to using the `aws/es` service KMS key"
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


variable "custom_endpoint" {
  type        = string
  description = "The domain name to use as custom endpoint for Elasicsearch"
  default     = null
}

variable "custom_endpoint_certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate to use for the custom endpoint. Required when custom endpoint is set along with enabling `endpoint_enforce_https`"
  default     = null
}

variable "auto_software_update_enabled" {
  type        = bool
  description = "Whether automatic service software updates are enabled for the domain"
  default     = true
}
