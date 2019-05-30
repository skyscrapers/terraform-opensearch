output "arn" {
  description = "ARN of the Elasticsearch domain"
  value       = "${element(concat(aws_elasticsearch_domain.es.*.arn, aws_elasticsearch_domain.public_es.*.arn), 0)}"
}

output "domain_id" {
  description = "ID of the Elasticsearch domain"
  value       = "${element(concat(aws_elasticsearch_domain.es.*.domain_id, aws_elasticsearch_domain.public_es.*.domain_id), 0)}"
}

output "domain_name" {
  description = "Name of the Elasticsearch domain"
  value       = "${element(concat(aws_elasticsearch_domain.es.*.domain_name, aws_elasticsearch_domain.public_es.*.domain_name), 0)}"
}

output "endpoint" {
  description = "DNS endpoint of the Elasticsearch domain"
  value       = "${element(concat(aws_elasticsearch_domain.es.*.endpoint, aws_elasticsearch_domain.public_es.*.endpoint), 0)}"
}

output "domain_region" {
  description = "Region of the Elasticsearch domain"
  value       = "${data.aws_region.current.name}"
}

output "sg_id" {
  description = "ID of the Elasticsearch security group"
  value       = "${join("", aws_security_group.sg.*.id)}"
}

output "role_arn" {
  description = "ARN of the IAM role (eg to attach to an instance or user) allowing access to the Elasticsearch snapshot bucket"
  value       = "${aws_iam_role.role.*.arn}"
}

output "role_id" {
  description = "ID of the IAM role (eg to attach to an instance or user) allowing access to the Elasticsearch snapshot bucket"
  value       = "${aws_iam_role.role.*.unique_id}"
}
