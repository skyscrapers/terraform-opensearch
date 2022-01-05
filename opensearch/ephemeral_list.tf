# m3 and r3 are supported by aws using ephemeral storage but are a legacy instance type
variable "ephemeral_list" {
  type = list(string)

  default = [
    "i3.large.search",
    "i3.xlarge.search",
    "i3.2xlarge.search",
    "i3.4xlarge.search",
    "i3.8xlarge.search",
    "i3.16xlarge.search",
    "r6gd.large.search",
    "r6gd.xlarge.search",
    "r6gd.2xlarge.search",
    "r6gd.4xlarge.search",
    "r6gd.8xlarge.search",
    "r6gd.12xlarge.search",
    "r6gd.16xlarge.search",
    ## Compatibility
    "i3.large.elasticsearch",
    "i3.xlarge.elasticsearch",
    "i3.2xlarge.elasticsearch",
    "i3.4xlarge.elasticsearch",
    "i3.8xlarge.elasticsearch",
    "i3.16xlarge.elasticsearch",
    "r6gd.large.elasticsearch",
    "r6gd.xlarge.elasticsearch",
    "r6gd.2xlarge.elasticsearch",
    "r6gd.4xlarge.elasticsearch",
    "r6gd.8xlarge.elasticsearch",
    "r6gd.12xlarge.elasticsearch",
    "r6gd.16xlarge.elasticsearch",
  ]
}
