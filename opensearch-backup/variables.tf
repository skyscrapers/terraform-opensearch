variable "name" {
  description = "Name for the snapshot system, S3 bucket, etc."
  type        = string
}

variable "aws_kms_key_arn" {
  description = "ARN of the CMK used for S3 Server Side Encryption. When specified, we'll use the `aws:kms` SSE algorithm. When not specified, falls back to using `AES256`"
  type        = string
  default     = null
}

variable "create_cron_expression" {
  description = "The cron schedule used to create snapshots"
  type        = string
  default     = "0 0 * * *"
}

variable "create_time_limit" {
  description = "Sets the maximum time to wait for snapshot creation to finish. If time_limit is longer than the scheduled time interval for taking snapshots, no scheduled snapshots are taken until time_limit elapses. For example, if time_limit is set to 35 minutes and snapshots are taken every 30 minutes starting at midnight, the snapshots at 00:00 and 01:00 are taken, but the snapshot at 00:30 is skipped"
  type        = string
  default     = "1h"
}

variable "delete_cron_expression" {
  description = "The cron schedule used to delete snapshots"
  type        = string
  default     = "0 2 * * *"
}

variable "delete_time_limit" {
  description = "Sets the maximum time to wait for snapshot deletion to finish"
  type        = string
  default     = "1h"
}

variable "max_age" {
  description = "The maximum time a snapshot is retained in S3"
  type        = string
  default     = "14d"
}

variable "indices" {
  description = "The names of the indexes in the snapshot. Multiple index names are separated by `,`. Supports wildcards (`*`)"
  type        = string
  default     = "*"
}

variable "custom_sm_policy" {
  description = "Set this variable when you want to override the generated SM policy JSON with your own. Make sure to correctly set `snapshot_config.repository` to the same value as `var.name` (the bucket name)"
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Whether to force-destroy and empty the S3 bucket when destroying this Terraform module. WARNING: Not recommended!"
  type        = bool
  default     = false
}
