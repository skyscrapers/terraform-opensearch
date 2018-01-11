variable "project" {
  description = "String(required): Project name"
}

variable "environment" {
  description = "String(required): Environment name"
}

variable "name" {
  description = "String(optional, \"es\"): Name to use for the Elasticsearch domain"
}

variable "version" {
  description = "String(optional, \"5.5\": Version of the Elasticsearch domain"
  default     = "5.5"
}

variable "access_policies" {
  description = "String(optional, \"\"): IAM policy document specifying the access policies for Elasticsearch"
  default     = ""
}

variable "advanced_options" {
  description = "List(optional, []): An Elasticsearch advanced_options block, which consists of Elasticsearch configuration options as key-value pairs"
  type        = "map"
  default     = {}
}

variable "logging_enabled" {
  description = "Bool(optional, false): Whether to enable Elasticsearch slow logs in Cloudwatch"
  default     = false
}

variable "logging_retention" {
  description = "Int(optional, 30): How many days to retain Elasticsearch logs in Cloudwatch"
  default     = 30
}

variable "instance_count" {
  description = "Int(optional, 1): Size of the Elasticsearch domain"
  default     = 1
}

variable "instance_type" {
  description = "String(optional, t2.small.elasticsearch): Instance type to use for the Elasticsearch domain"
  default     = "t2.small.elasticsearch"
}

variable "dedicated_master_enabled" {
  description = "Bool(optional, false): Whether dedicated master nodes are enabled for the domain"
  default     = false
}

variable "dedicated_master_type" {
  description = "String(optional, t2.small.elasticsearch): Instance type of the dedicated master nodes in the domain"
  default     = "t2.small.elasticsearch"
}

variable "dedicated_master_count" {
  description = "Int(optional, 1): Number of dedicated master nodes in the domain"
  default     = 1
}

variable "volume_type" {
  description = "String(optional, \"gp2\"): EBS volume type to use for the Elasticsearch domain"
  default     = "gp2"
}

variable "volume_size" {
  description = "Int(required): EBS volume size (in GB) to use for the Elasticsearch domain"
}

variable "volume_iops" {
  description = "Int(required if volume_type=\"io1\"): Amount of provisioned IOPS for the EBS volume"
  default     = 0
}

variable "vpc_id" {
  description = "String(required): VPC ID where to deploy the Elasticsearch domain"
}

variable "subnet_ids" {
  description = "List(required): Subnet IDs for the Elasticsearch domain endpoints to be created in"
  type        = "list"
}

variable "security_group_ids" {
  description = "List(optional): Extra security group IDs to attach to the Elasticsearch domain. Note: a default SG is already created and exposed via outputs"
  type        = "list"
  default     = []
}

variable "snapshot_start_hour" {
  description = "Int(optional, 3): Hour during which an automated daily snapshot is taken of the Elasticsearch indices"
  default     = 3
}

variable "snapshot_bucket_enabled" {
  description = "Bool(optional, false): Whether to create a bucket for custom Elasticsearch backups (other than the default daily one)"
  default     = false
}

variable "tags" {
  description = "Map(optional, {}): Optional tags"
  type        = "map"
  default     = {}
}

variable "zone_awareness_enabled" {
  default = true
}
