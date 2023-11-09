variable "name" {
  description = "Name for the snapshot system, S3 bucket, etc."
  type        = string
}

variable "aws_kms_key_arn" {
  description = "ARN of the CMK used for S3 Server Side Encryption. When specified, we'll use the `aws:kms` SSE algorithm. When not specified, falls back to using `AES256`"
  type        = string
  default     = null
}

variable "snapshots_schedule" {
  description = "Snapshot frequency specified as cron"
  type        = string
  default     = "TODO"
}

variable "snapshots_retention" {
  description = "How many days to retain the OpenSearch snapshots in S3"
  type        = number
  default     = 14
}

variable "force_destroy" {
  description = "Whether to force-destroy and empty the S3 bucket when destroying this Terraform module. WARNING: Not recommended!"
  type        = bool
  default     = false
}
