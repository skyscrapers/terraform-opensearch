# List all instances which support encryption at rest
# https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/aes-supported-instance-types.html
variable "encryption_list" {
  type = list(string)

  default = [
    "m4.large.elasticsearch",
    "m4.xlarge.elasticsearch",
    "m4.2xlarge.elasticsearch",
    "m4.4xlarge.elasticsearch",
    "m4.10xlarge.elasticsearch",
    "c4.large.elasticsearch",
    "c4.xlarge.elasticsearch",
    "c4.2xlarge.elasticsearch",
    "c4.4xlarge.elasticsearch",
    "c4.8xlarge.elasticsearch",
    "r4.large.elasticsearch",
    "r4.xlarge.elasticsearch",
    "r4.2xlarge.elasticsearch",
    "r4.4xlarge.elasticsearch",
    "r4.8xlarge.elasticsearch",
    "r4.16xlarge.elasticsearch",
    "i2.xlarge.elasticsearch",
    "i2.2xlarge.elasticsearch",
    "i3.large.elasticsearch",
    "i3.xlarge.elasticsearch",
    "i3.2xlarge.elasticsearch",
    "i3.4xlarge.elasticsearch",
    "i3.8xlarge.elasticsearch",
    "i3.16xlarge.elasticsearch",
  ]
}

