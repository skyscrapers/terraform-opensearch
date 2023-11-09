module "s3_snapshot" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.15"

  bucket = var.name

  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.aws_kms_key_arn
        sse_algorithm     = var.aws_kms_key_arn != null ? "aws:kms" : "AES256"
      }
    }
  }

  versioning = {
    enabled = false
  }

  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_snapshot_bucket.json
}

data "aws_iam_policy_document" "s3_snapshot_bucket" {
  statement {
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "${module.s3_snapshot.s3_bucket_arn}/*",
    ]

    condition {
      test     = "ForAnyValue:StringNotEquals"
      variable = "aws:PrincipalArn"

      values = [
        aws_iam_role.snapshot_create.arn
      ]
    }
  }

  #statement {}  # Replication?
}
