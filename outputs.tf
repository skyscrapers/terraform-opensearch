output "arn" {
  description = "ARN of the Elasticsearch domain"
  value       = "${aws_elasticsearch_domain.es.arn}"
}

output "domain_id" {
  description = "ID of the Elasticsearch domain"
  value       = "${aws_elasticsearch_domain.es.domain_id}"
}

output "endpoint" {
  description = "DNS endpoint of the Elasticsearch domain"
  value       = "${aws_elasticsearch_domain.es.endpoint}"
}

output "sg_id" {
  description = "ID of the Elasticsearch security group"
  value       = "${aws_security_group.sg.id}"
}

output "role_arn" {
  description = "ARN of the IAM role (eg to attach to an instance or user) allowing access to the Elasticsearch snapshot bucket"
  value       = "${aws_iam_role.role.*.arn}"
}

output "role_id" {
  description = "ID of the IAM role (eg to attach to an instance or user) allowing access to the Elasticsearch snapshot bucket"
  value       = "${aws_iam_role.role.*.unique_id}"
}
