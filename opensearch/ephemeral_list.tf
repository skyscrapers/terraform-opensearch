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
    "r6gd.16xlarge.search"
  ]
}
