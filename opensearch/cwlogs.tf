resource "aws_cloudwatch_log_group" "cwl_index" {
  name              = "${var.name}/index_slow_logs"
  retention_in_days = var.logging_retention
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "cwl_search" {
  name              = "${var.name}/search_slow_logs"
  retention_in_days = var.logging_retention
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "cwl_application" {
  name              = "${var.name}/application_logs"
  retention_in_days = var.logging_retention
  tags              = var.tags
}

data "aws_iam_policy_document" "cwl_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.cwl_index.arn}:*",
      "${aws_cloudwatch_log_group.cwl_search.arn}:*",
      "${aws_cloudwatch_log_group.cwl_application.arn}:*",
    ]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "cwl_resource_policy" {
  policy_name     = "${var.name}-cwl-policy"
  policy_document = data.aws_iam_policy_document.cwl_policy.json
}
