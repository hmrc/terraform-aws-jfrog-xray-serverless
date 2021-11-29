# TODO: username/password are deprecated, need to use a bearer token
provider "artifactory" {
  url      = "${var.artifactory_url}/artifactory"
  username = "admin"
  password = "password"
}
