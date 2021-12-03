// provider "curl"{
//   secret = "admin:password"
// }

# TODO: username/password are deprecated, need to use a bearer token
provider "artifactory" {
  url      = "${var.artifactory_url}/artifactory"
  username = local.username
  password = local.password
  // bearer_token = local.bearer_token
}


// data "curl" "create_bearer_token"{
//   http_method= "POST"
//   uri = "-u 'admin:password' http://jfrog-xray-k15wr-artifactory-1775471376.eu-west-2.elb.amazonaws.com/artifactory/api/security/token -d 'username=admin' -d 'scope=member-of-groups:admins'"
// }

// locals {
//   json_output = jsondecode(data.curl.create_bearer_token.response)
// }

// output "bearer_token"{
//   value = local.json_output
// }