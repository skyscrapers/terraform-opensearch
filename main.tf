resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.project}-${var.environment}-${var.name}"
  access_policies       = "${var.access_policies}"
  advanced_options      = "${var.advanced_options}"
  elasticsearch_version = "${var.version}"

  cluster_config {
    instance_count           = "${var.instance_count}"
    instance_type            = "${var.instance_type}"
    dedicated_master_enabled = "${var.dedicated_master_enabled}"
    dedicated_master_count   = "${var.dedicated_master_count}"
    dedicated_master_type    = "${var.dedicated_master_type}"
    zone_awareness_enabled   = true
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "${var.volume_type}"
    volume_size = "${var.volume_size}"
    iops        = "${var.volume_type == "io1" ? var.volume_iops : 0}"
  }

  log_publishing_options {
    enabled                  = true
    log_type                 = "${var.log_type}"
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.cwl.arn}"
  }

  snapshot_options {
    automated_snapshot_start_hour = "${var.snapshot_start_hour}"
  }

  vpc_options {
    security_group_ids = ["${aws_security_group.sg.id}", "${var.security_group_ids}"]
    subnet_ids         = ["${var.subnet_ids}"]
  }

  # TF has no support yet for encryption at rest. Waiting for the PR to be merged:
  # https://github.com/terraform-providers/terraform-provider-aws/pull/2632
  # encrypt_at_rest {
  #   enabled = "${var.encrypt_at_rest}"
  # }

  tags = "${merge("${var.tags}",
    map("Name", "${var.project}-${var.environment}-${var.name}",
      "Environment", "${var.environment}",
      "Project", "${var.project}"))
  }"
}

resource "aws_cloudwatch_log_group" "cwl" {
  name              = "${var.project}-${var.environment}-${var.name}"
  retention_in_days = "${var.log_retention}"

  tags = "${merge("${var.tags}",
    map("Name", "${var.project}-${var.environment}-${var.name}",
      "Environment", "${var.environment}",
      "Project", "${var.project}"))
  }"
}

resource "aws_s3_bucket" "snapshot" {
  count  = "${var.snapshot_bucket_enabled ? 1 : 0}"
  bucket = "${var.project}-${var.environment}-${var.name}-snapshot"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = "${merge("${var.tags}",
    map("Name", "${var.project}-${var.environment}-${var.name}-snapshot",
      "Environment", "${var.environment}",
      "Project", "${var.project}"))
  }"
}
