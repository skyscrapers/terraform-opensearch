resource "opensearch_snapshot_repository" "repo" {
  name = module.s3_snapshot.s3_bucket_id
  type = "s3"

  settings = {
    bucket                 = module.s3_snapshot.s3_bucket_id
    region                 = module.s3_snapshot.s3_bucket_region
    role_arn               = aws_iam_role.snapshot_create.arn
    server_side_encryption = true
  }
}

## TODO Create SM, not available yet
## https://github.com/opensearch-project/terraform-provider-opensearch/issues/70
resource "opensearch_sm_policy" "snapshot" {
  policy_name = "snapshot_to_${var.name}"

  body = var.custom_sm_policy != null ? var.custom_sm_policy : templatefile("${path.module}/templates/snapshot_to_s3_sm.json.tftpl", {
    name                   = var.name
    create_cron_expression = var.create_cron_expression
    create_time_limit      = var.create_time_limit
    delete_cron_expression = var.delete_cron_expression
    delete_time_limit      = var.delete_time_limit
    max_age                = var.max_age
    max_count              = var.max_count
    min_count              = var.min_count
    indices                = var.indices
    repository             = opensearch_snapshot_repository.repo.name
  })
}
