locals {
  vpc_enabled = "${var.vpc_id == "" ? false : true}"

  tags = "${merge("${var.tags}",
    map("Name", "${var.project}-${var.environment}-${var.name}",
      "Environment", "${var.environment}",
      "Project", "${var.project}"))
  }"

  tags_noname = "${merge("${var.tags}",
    map("Environment", "${var.environment}",
      "Project", "${var.project}"))
  }"

  cluster_config = {
    instance_count           = "${var.instance_count}"
    instance_type            = "${var.instance_type}"
    dedicated_master_enabled = "${var.dedicated_master_enabled}"
    dedicated_master_count   = "${var.dedicated_master_enabled ? var.dedicated_master_count : 0}"
    dedicated_master_type    = "${var.dedicated_master_enabled ? var.dedicated_master_type : ""}"
    zone_awareness_enabled   = "${var.instance_count > 1 ? true : false}"
  }

  ebs_options = {
    ebs_enabled = true
    volume_type = "${var.volume_type}"
    volume_size = "${var.volume_size}"
    iops        = "${var.volume_type == "io1" ? var.volume_iops : 0}"
  }

  snapshot_options = {
    automated_snapshot_start_hour = "${var.snapshot_start_hour}"
  }
}

resource "aws_elasticsearch_domain" "es" {
  count                 = "${local.vpc_enabled ? 1 : 0}"
  domain_name           = "${var.project}-${var.environment}-${var.name}"
  elasticsearch_version = "${var.elasticsearch_version}"
  cluster_config        = ["${local.cluster_config}"]
  ebs_options           = ["${local.ebs_options}"]
  snapshot_options      = ["${local.snapshot_options}"]
  tags                  = "${local.tags}"

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "${var.options_rest_action_multi_allow_explicit_index}"
    "indices.fielddata.cache.size"           = "${var.options_indices_fielddata_cache_size}"
    "indices.query.bool.max_clause_count"    = "${var.options_indices_query_bool_max_clause_count}"
  }

  log_publishing_options {
    enabled                  = "${var.logging_enabled}"
    log_type                 = "INDEX_SLOW_LOGS"
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.cwl_index.arn}"
  }

  log_publishing_options {
    enabled                  = "${var.logging_enabled}"
    log_type                 = "SEARCH_SLOW_LOGS"
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.cwl_search.arn}"
  }

  vpc_options {
    security_group_ids = ["${aws_security_group.sg.id}", "${var.security_group_ids}"]
    subnet_ids         = ["${var.subnet_ids}"]
  }
}

resource "aws_elasticsearch_domain" "public_es" {
  count                 = "${local.vpc_enabled ? 0 : 1}"
  domain_name           = "${var.project}-${var.environment}-${var.name}"
  elasticsearch_version = "${var.elasticsearch_version}"
  cluster_config        = ["${local.cluster_config}"]
  ebs_options           = ["${local.ebs_options}"]
  snapshot_options      = ["${local.snapshot_options}"]
  tags                  = "${local.tags}"

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "${var.options_rest_action_multi_allow_explicit_index}"
    "indices.fielddata.cache.size"           = "${var.options_indices_fielddata_cache_size}"
    "indices.query.bool.max_clause_count"    = "${var.options_indices_query_bool_max_clause_count}"
  }

  log_publishing_options {
    enabled                  = "${var.logging_enabled}"
    log_type                 = "INDEX_SLOW_LOGS"
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.cwl_index.arn}"
  }

  log_publishing_options {
    enabled                  = "${var.logging_enabled}"
    log_type                 = "SEARCH_SLOW_LOGS"
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.cwl_search.arn}"
  }
}

resource "aws_cloudwatch_log_group" "cwl_index" {
  name              = "${var.project}/${var.environment}/${var.name}/index_slow_logs"
  retention_in_days = "${var.logging_retention}"
  tags              = "${local.tags_noname}"
}

resource "aws_cloudwatch_log_group" "cwl_search" {
  name              = "${var.project}/${var.environment}/${var.name}/search_slow_logs"
  retention_in_days = "${var.logging_retention}"
  tags              = "${local.tags_noname}"
}

resource "aws_s3_bucket" "snapshot" {
  count  = "${var.snapshot_bucket_enabled ? 1 : 0}"
  bucket = "${var.project}-${var.environment}-${var.name}-snapshot"
  acl    = "private"
  tags   = "${local.tags}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}
