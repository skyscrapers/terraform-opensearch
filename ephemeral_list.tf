# List all instances which support encryption at rest
# https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/aes-supported-instance-types.html

# m3 and r3 are supported by aws using ephemeral storage but are a lecacy instance type
variable "ephemeral_list" {
  type = "list"

  default = [
    "i2.xlarge.elasticsearch",
    "i2.2xlarge.elasticsearch",
    "i3.large.elasticsearch",
    "i3.xlarge.elasticsearch",
    "i3.2xlarge.elasticsearch",
    "i3.4xlarge.elasticsearch",
    "i3.8xlarge.elasticsearch",
    "i3.16xlarge.elasticsearch",
  ]

  # "m3.medium.elasticsearch",
  # "m3.large.elasticsearch",
  # "m3.xlarge.elasticsearch",
  # "m3.2xlarge.elasticsearch",
  # "r3.large.elasticsearch",
  # "r3.xlarge.elasticsearch",
  # "r3.2xlarge.elasticsearch",
  # "r3.4xlarge.elasticsearch",
  # "r3.8xlarge.elasticsearch",
}
