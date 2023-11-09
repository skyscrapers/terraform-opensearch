resource "opensearch_snapshot_repository" "repo" {
  name = module.s3_snapshot.s3_bucket_id
  type = "s3"

  settings = {
    bucket   = module.s3_snapshot.s3_bucket_id
    region   = module.s3_snapshot.s3_bucket_region
    role_arn = aws_iam_role.snapshot_create.arn
  }
}

## TODO Create SM, not available yet
## https://github.com/opensearch-project/terraform-provider-opensearch/issues/70
# resource "opensearch_sm_policy" "snapshot" {
#   policy_id = "snapshot_to_${var.name}"
#   body = templatefile("${path.module}/templates/snapshot_to_s3_sm.json.tftpl",
#   )
# }
