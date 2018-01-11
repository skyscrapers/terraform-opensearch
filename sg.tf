resource "aws_security_group" "sg" {
  name        = "${var.project}-${var.environment}-${var.name}"
  description = "Security group for the ${var.project} Elasticsearch domain"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge("${var.tags}",
    map("Name", "${var.project}-${var.environment}-${var.name}",
      "Environment", "${var.environment}",
      "Project", "${var.project}"))
  }"
}
